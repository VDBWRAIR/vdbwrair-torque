class torque::sched (
    $service_options     = $torque::params::server_service_options,
) inherits torque {
    validate_array($service_options)

    class{ 'torque::sched::config': } ->
    class{ 'torque::sched::service': }
}
