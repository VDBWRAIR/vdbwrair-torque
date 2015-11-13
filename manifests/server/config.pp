class torque::server::config inherits torque::server {
    $sconfig = torque_config_diff('server', $qmgr_server)
    $qconfig = torque_config_diff('queue', $qmgr_queues, $qmgr_queue_defaults)

    file { "${torque::torque_home}/server_priv":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0751',
        require => Class['torque::server::install']
    }

    $server_priv_dirs = [
        "${torque::torque_home}/server_priv/jobs",
        "${torque::torque_home}/server_priv/acl_users",
        "${torque::torque_home}/server_priv/queues",
        "${torque::torque_home}/server_priv/acl_svr",
        "${torque::torque_home}/server_priv/credentials",
        "${torque::torque_home}/server_priv/arrays",
        "${torque::torque_home}/server_priv/hostlist",
        "${torque::torque_home}/server_priv/acl_hosts",
        "${torque::torque_home}/server_priv/disallowed_types",
        "${torque::torque_home}/server_priv/acl_groups",
    ]
    file { $server_priv_dirs:
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        require => File["${torque::torque_home}/server_priv"]
    }

    file { "${torque::torque_home}/server_priv/accounting":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File["${torque::torque_home}/server_priv"]
    }

    file { "${torque::torque_home}/server_logs":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0750',
        require => File["${torque::torque_home}"]
    }

    Concat::Fragment <<| tag == "torque_server_${torque::torque_server}" |>>
    Host <<| tag == "torque_host_server_${torque::torque_server}" |>>

    file { "${torque::torque_home}/server_priv/qmgr_config":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => template('torque/qmgr_config.erb'),
    }

    exec { 'qmgr update':
        path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        command     => "cat ${torque::torque_home}/server_priv/qmgr_config | qmgr",
        #onlyif      => "cat ${torque::torque_home}/server_priv/qmgr_config ",
        onlyif      => "diff <(cat ${torque::torque_home}/server_priv/qmgr_config | sort) <(qmgr -c 'print server' | sort)",
        refreshonly => true,
        subscribe   => File["${torque::torque_home}/server_priv/qmgr_config"],
        logoutput   => true,
        require     => [
            Class['torque::server::install']
        ]
    }

    concat{ "${torque_home}/server_priv/nodes":
        owner  => root,
        group  => root,
        mode   => '0644',
        notify => Service['pbs_server']
    }

    file {"/etc/ld.so.conf.d/torque.conf":
        content => "${prefix}/lib",
        mode => '0444',
    }
}
