class torque::sched::service inherits torque::sched {
    $sched_service_file = $::osfamily ? {
        'Debian' => 'debian.pbs_sched',
        'Suse'   => 'suse.pbs_sched',
        default  => 'pbs_sched'
    }
    $sched_service_file_source = "${torque::build_dir}/contrib/init.d/${sched_service_file}"
    torque::service { 'pbs_sched':
        ensure              => 'running',
        enable              => true,
        service_file_source => $sched_service_file_source,
        service_options     => $torque::sched::service_options,
        subscribe           => Service['pbs_server']
    }
}
