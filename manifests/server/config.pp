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
        require => File["${torque::torque_home}/server_priv"],
        notify  => Exec['pbs_server_init']
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
    Firewall <<| tag == "torque_fw_server_${torque::torque_server}" |>>

    # Have to run -t create first otherwise first time
    # the service runs it will destroy torque_home/server_priv
    # This seems to destroy files inside of server_priv such as nodes and
    # qmgr_config
    exec { "pbs_server_init":
        command => "/usr/local/sbin/pbs_server -f -t create -d ${torque::torque_home}",
        creates => "${torque::torque_home}/server_priv/serverdb"
    }


    file { "${torque::torque_home}/server_priv/qmgr_config":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => template('torque/qmgr_config.erb'),
        notify  => Exec['qmgr_update'],
        require => Exec['pbs_server_init']
    }

    concat{ "${torque_home}/server_priv/nodes":
        owner  => root,
        group  => root,
        mode   => '0644',
        notify => Service['pbs_server'],
        require => Exec['pbs_server_init']
    }

    file {"/etc/ld.so.conf.d/torque.conf":
        content => "${prefix}/lib",
        mode => '0444',
    }
}
