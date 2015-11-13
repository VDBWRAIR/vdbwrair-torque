class torque::mom::config inherits torque::mom {
    # Exports this mom so server can
    # pick it up and include it
    @@concat::fragment{ "torque_mom_${::fqdn}":
        target  => "${torque::torque_home}/server_priv/nodes",
        content => template("${module_name}/client.erb"),
        tag     => 'torque'
    }
    # Exports host entry for this mom
    @@host { $::fqdn:
        ip           => $::ipaddress,
        host_aliases => [$::hostname],
        tag          => ['torque_host'],
    }

    file { "${torque::torque_home}/mom":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { "${torque::torque_home}/mom_priv":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0751',
        require => File["${torque::torque_home}/mom"]
    }

    file { "${torque::torque_home}/mom_priv/config":
        ensure  => 'present',
        content => template('torque/pbs_config.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        require => File["${torque::torque_home}/mom_priv"],
    }

    file { "${torque::torque_home}/undelivered":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
    }

    file { "${torque::torque_home}/checkpoint":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
    }

    file { "${torque::torque_home}/aux":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755'
    }

    file { "${torque::torque_home}/spool":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
    }

    file { "${torque::torque_home}/mom_priv/jobs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0751'
    }

    if $mom_options['tmpdir'] {
        exec {"/bin/mkdir -p ${torque::mom::options[tmpdir]}":
            unless => "/usr/bin/test -d ${torque::mom::options[tmpdir]}"
        }
        file {$options['tmpdir']:
            ensure => directory,
            owner => root,
            group => root,
            mode => '1733',
            require => Exec["/bin/mkdir -p ${torque::options[tmpdir]}"]
        }
    }
}
