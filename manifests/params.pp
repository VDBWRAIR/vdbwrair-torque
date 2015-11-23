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
    # Lines for pbs_environment file
    $pbs_environment            = [
        'PATH=/bin:/usr/bin',
        'LANG=en_US.UTF-8',
        'BASH_ENV=/etc/bashrc',
        'ENV=/etc/bashrc'
    ]

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

    ## Server
    # Options from pbs_server_attributes man page
    $server_qmgr                = [
        "acl_hosts = ${::fqdn}",
        'node_check_rate = 150',
        'tcp_timeout = 6',
        'scheduling = True',
        'acl_host_enable = False',
        "managers = root@${::fqdn}",
        "operators = root@${::fqdn}",
        'log_events = 511',
        'mail_from = adm',
        'mail_domain = never',
        'query_other_jobs = True',
        'scheduler_iteration = 600',
        'node_pack = False',
        'kill_delay = 10',
        'job_stat_rate = 300',
        'nppcu = 1',
        'poll_jobs = True',
        'moab_array_compatible = True',
        'mom_job_sync = True'
    ]
    # These are the defaults that will be assigned to each queue if not specified
    $server_qmgr_queue_defaults        = [
        'queue_type = Execution',
        'resources_max.cput = 48:00:00',
        'resources_max.walltime = 72:00:00',
        'enabled = True',
        'started = True',
        'acl_group_enable = True',
    ]
    # default queue definitions
    # this is a hash with the queue name as key and an array of configuration options as value
    # if no value is specified then the default options array ($qmgr_qdefaults) is used
    # Look at man pbs_queue_attributes for details on what you can set
    $server_qmgr_queues                = {
        'batch' => [
            'queue_type = Execution',
            'Priority = 50',
            'resources_default.nodes = 1',
            'resources_default.walltime = 168:00:00',
            'disallowed_types = interactive',
            'keep_completed = 3600',
            'enabled = True',
            'started = True'
        ]
    }
    # Args to pass to pbs_server service
    $server_service_options        = [
        "-L /var/log/torque/pbs_server.log"
    ]
    $scheduler_class               = 'torque::sched'
    $scheduler_options             = {
        'service_options' => ["-L /var/log/torque/pbs_sched.log"]
    }
}
