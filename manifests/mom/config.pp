class torque::mom::config inherits torque::mom {
    # Exports this mom so server can
    # pick it up and include it
    @@concat::fragment{ "torque_mom_${::fqdn}":
        target  => "${torque::torque_home}/server_priv/nodes",
        content => template("${module_name}/client.erb"),
        tag     => "torque_server_${torque::torque_server}"
    }
    # Exports host entry for this mom
    @@host { $::fqdn:
        ip           => $::ipaddress,
        host_aliases => [$::hostname],
        tag          => ["torque_host_server_${torque::torque_server}"],
    }
    # Exports firewall rules to server
    @@firewall { "500 accept pbs_mom all from ${::ipaddress}":
        proto       => 'all',
        action      => 'accept',
        source      => $::ipaddress,
        tag         => "torque_fw_server_${torque::torque_server}"
    }

    firewall { '500 accept pbs_server all':
        proto       => 'all',
        action      => 'accept',
        source      => "${torque::torque_server}"
    }

    file { "${torque::torque_home}/mom_priv":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755', # Has to be 755 for pam_pbssimpleauth.so
        require => Class['torque::mom::install']
    }

    file { "${torque::torque_home}/mom_logs":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        require => File["${torque::torque_home}"]
    }

    file { "${torque::torque_home}/mom_priv/config":
        ensure  => 'present',
        content => template('torque/pbs_config.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        require => File["${torque::torque_home}/mom_priv"],
        notify  => Service['pbs_mom']
    }

    file { "${torque::torque_home}/mom_priv/jobs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755', # Has to be 755 for pam_pbssimpleauth.so
        require => File["${torque::torque_home}/mom_priv"],
    }

    if $options['tmpdir'] {
        exec {"/bin/mkdir -p ${torque::mom::options[tmpdir]}":
            unless => "/usr/bin/test -d ${torque::mom::options[tmpdir]}"
        }
        file {$options['tmpdir']:
            ensure => directory,
            owner => root,
            group => root,
            mode => '1733',
            require => Exec["/bin/mkdir -p ${torque::mom::options['tmpdir']}"]
        }
    }

    if $with_pam {
        pam { "enable_pam_pbssimpleauth":
            ensure    => present,
            service   => 'sshd',
            type      => 'account',
            control   => 'sufficient',
            module    => 'pam_pbssimpleauth.so',
            arguments => 'debug',
            position  => 'before *[type="account" and module="password-auth"]',
            require   => Class['torque::mom::install']
        }
        pam { "enable_pam_access":
            ensure    => present,
            service   => 'sshd',
            type      => 'account',
            control   => 'required',
            module    => 'pam_access.so',
            position  => 'after *[type="account" and module="pam_pbssimpleauth.so"]',
            require   => Pam['enable_pam_pbssimpleauth']
        }
        # insert blanket deny all
        # No entries in access.conf
        augeas {"ensure_deny_all_default_no_previous_rules":
                context => "/files/etc/security/access.conf",
                changes => [
                        'set access -',
                        'set access/user ALL',
                        'set access/origin ALL',
                ],
                onlyif  => "match access size == 0"
        }
        # > 0 entries in access.conf
        augeas {"ensure_deny_all_default_some_previous_rules":
                context => "/files/etc/security/access.conf",
                changes => [
                        'ins access after access[last()]',
                        'set access[last()] -',
                        'set access[last()]/group ALL',
                        'set access[last()]/origin ALL'
                ],
                onlyif  => "match access[. = '-'][user = 'ALL'][origin = 'ALL'] size == 0"
        }

        # If group entry doesn't exist
        augeas {"ensure_${torque::mom::access_group}_access":
                context => "/files/etc/security/access.conf",
                changes => [
                        'ins access before access[last()]',
                        'set access[last()-1] +',
                        'set access[last()-1]/user root',
                        "set access[last()-1]/group ${torque::mom::access_group}",
                        'set access[last()-1]/origin ALL'
                ],
                onlyif  => "match access[. = '+'][group = '${torque::mom::access_group}'][user = 'root'][origin = 'ALL'] size == 0",
                require => [
                        Augeas['ensure_deny_all_default_no_previous_rules'],
                        Augeas['ensure_deny_all_default_some_previous_rules'],
                ]
        }
        file { "/root/pam_pbssimpleauth.te":
            ensure	=> file,
            owner	=> root,
            group	=> root,
            mode	=> '0600',
            source	=> 'puppet:///modules/torque/pam_pbssimpleauth.te',
            notify	=> Exec['build_selinux_mod']
        }
        exec { "build_selinux_mod":
            path	=> '/bin:/usr/bin:/usr/sbin',
            command => 'checkmodule -M -m -o /root/pam_pbssimpleauth.mod /root/pam_pbssimpleauth.te',
            creates => '/root/pam_pbssimpleauth.mod',
            require	=> File['/root/pam_pbssimpleauth.te']
        }
        exec { "build_selinux_pp":
            path	=> '/bin:/usr/bin:/usr/sbin',
            command => 'semodule_package -o /root/pam_pbssimpleauth.pp -m /root/pam_pbssimpleauth.mod',
            creates	=> '/root/pam_pbssimpleauth.pp',
            require	=> Exec['build_selinux_mod']
        }
        exec { "install_selinux_pp":
            path	=> '/bin:/usr/bin:/usr/sbin',
            command => 'semodule -i /root/pam_pbssimpleauth.pp',
            unless	=> 'semodule -l | grep pam_pbssimpleauth',
            require	=> Exec['build_selinux_mod']
        }
    }
}
