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
        subscribe           => Service['trqauthd']
    }
}
