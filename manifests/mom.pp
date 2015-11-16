class torque::mom (
    $options            = $torque::params::mom_options,
    $usecp              = $torque::params::mom_usecp,
    $service_options    = $torque::params::mom_service_options,
) inherits torque::build {
    validate_hash($options)
    validate_array($usecp)
    validate_integer($options['logevent'])
    validate_array($service_options)

    #anchor { 'module::begin': } ->
        class{ 'torque::mom::install': } ->
        #class{ 'torque::config': } ->
        class{ 'torque::mom::config': } ->
        class{ 'torque::mom::service': }
    #anchor { 'module::end': }
}
