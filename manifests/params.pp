class torque::params {
    # Use logrotate for rotating logs
    $use_logrotate              = true
    # Where torque config lives
    $torque_home                = "/var/spool/torque"
    # Version of torque to build
	$version 	                = "5.1.1.2-1_18e4a5f1"
    # Where to do the build from
    $build_dir                  = "/opt/torque-${version}"
    # The base url to search for $version
    $torque_base_url            = "http://wpfilebase.s3.amazonaws.com/torque"
    # Options to use while running ./configure
    $configure_options          = [
        "--with-server-home=${torque::torque_home}"
    ]
    # Where to install binaries
    $install_prefix             = "/usr/local"

    ## Mom args
    # Any options for pbs_config file
    $mom_options                = {
        logevent => 255
    }
    # usecp lines one per element in the array
    # used in pbs_config file
    $mom_usecp                  = [
    ]
    # Args to pass to pbs_mom service
    $mom_service_options        = [
        "-L /var/log/torque/pbs_mom.log"
    ]
}
