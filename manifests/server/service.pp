class torque::server::service inherits torque::server {
    $service_file = $::osfamily ? {
        'Debian' => 'debian.pbs_server',
        'Suse'   => 'suse.pbs_server',
        default  => 'pbs_server'
    }
    $trq_service_file = $::osfamily ? {
        'Debian' => 'debian.trqauthd',
        'Suse'   => 'suse.trqauthd',
        default  => 'trqauthd'
    }

    $trq_service_file_source = "${torque::build_dir}/contrib/init.d/${trq_service_file}"
    torque::service { 'trqauthd':
        ensure => 'running',
        enable => true,
        service_file_source => $trq_service_file_source,
        require => Class['torque::server::config']
    }

    $service_file_source = "${torque::build_dir}/contrib/init.d/${service_file}"
    torque::service { 'pbs_server':
        ensure              => 'running',
        enable              => true,
        service_file_source => $service_file_source,
        service_options     => $torque::server::server_service_options,
        subscribe           => Service['trqauthd'],
        require             => Class['torque::server::config']
    }

    # Realistically this should be in server/config.pp but because it requires
    # that pbs_server is running it has to be here. I'm sure there is a better
    # way to do it since it isn't fitting into the install->config->service model
    # but for now we put it here
    exec { 'qmgr_update':
        path        => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        command     => "cat ${torque::torque_home}/server_priv/qmgr_config | qmgr",
        unless      => "bash -c \"diff <(cat ${torque::torque_home}/server_priv/qmgr_config | sort) <(qmgr -c 'print server' | sort)\"",
        logoutput   => true,
        require     => [
            Class['torque::server::install'],
            Service['pbs_server']
        ],
    }

}
