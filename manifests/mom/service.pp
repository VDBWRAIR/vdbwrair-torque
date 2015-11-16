class torque::mom::service inherits torque::mom {
    $service_file = $::osfamily ? {
        'Debian' => 'debian.pbs_mom',
        'Suse'   => 'suse.pbs_mom',
        default  => 'pbs_mom'
    }

    $service_file_source = "${torque::build_dir}/contrib/init.d/${service_file}"

    torque::service { 'pbs_mom':
        ensure => 'running',
        enable => true,
        service_file_source => $service_file_source,
        service_options => $torque::mom::service_options,
        require => Class['torque::mom::config']
    }
}
