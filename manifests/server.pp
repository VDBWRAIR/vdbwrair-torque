class torque::server (
    $qmgr_server                = $torque::params::server_qmgr,
    $qmgr_queue_defaults        = $torque::params::server_qmgr_queue_defaults,
    $qmgr_queues                = $torque::params::server_qmgr_queues,
    $server_service_options     = $torque::params::server_service_options,
    $scheduler_class            = $torque::params::scheduler_class,
    $scheduler_options          = $torque::params::scheduler_options,
) inherits torque::build {
    validate_array($qmgr_server)
    validate_array($qmgr_queue_defaults)
    validate_hash($qmgr_queues)
    validate_array($server_service_options)
    validate_string($scheduler_class)
    validate_hash($scheduler_options)

    #anchor { 'module::begin': } ->
        class{ 'torque::server::install': } ->
        #class{ 'torque::config': }
        class{ 'torque::server::config': } ->
        class{ 'torque::server::service': }
    #anchor { 'module::end': }

    if !empty($scheduler_class) {
        create_resources('class', {
            $scheduler_class => $scheduler_options
        })
    }
}
