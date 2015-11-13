define torque::service(
    $ensure,
    $enable,
    $service_file_source,
    $service_options,
    $torque_home            = $torque::params::torque_home,
    $use_logrotate          = $torque::params::use_logrotate
) {
    validate_re($ensure, ['^running$','^stopped$','^absent$'])
    validate_bool($enable)
    validate_absolute_path($service_file_source)
    validate_absolute_path($torque_home)
    validate_array($service_options)
    validate_bool($use_logrotate)

    $service_name = $name

    $service_default_file = $::osfamily ? {
        "Debian" => "/etc/default/${service_name}",
        "RedHat" => "/etc/sysconfig/${service_name}",
        default  => fail('Unsupported operating system')
    }

    file {"/etc/init.d/${service_name}":
        source => $service_file_source,
        mode => "0755",
        owner => root,
        group => root
    }

    case $::osfamily {
        'RedHat': {
            # See https://github.com/adaptivecomputing/torque/pull/330
            file_line {"ensure_pbs_args_in_${service_name}":
                path => $service_file_source,
                line => 'PBS_ARGS=""',
                match => '^PBS_ARGS=',
                after => "PBS_HOME=${torque_home}",
                before => File["/etc/init.d/${service_name}"]
            }
            exec {"add_daemon_pbs_args_${service_name}":
                command => "/bin/sed -i -E 's/(daemon \\\$PBS_DAEMON)(.*)(-d \\\$PBS_HOME)/\\1\\2\\3 \$PBS_ARGS/' ${service_file_source}",
                unless => "/bin/grep -qE \'daemon.*\\\$PBS_ARGS\' ${service_file_source}",
                before => File["/etc/init.d/${service_name}"]
            }
        }
    }

    file { $service_default_file:
        ensure  => present,
        content => template("${module_name}/${::osfamily}.service_default.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service[$service_name],
    }

    service { $service_name:
        ensure     => $ensure,
        enable     => $enable,
        subscribe  => [
            File["/etc/init.d/${service_name}"],
            File["${torque_home}/server_name"],
        ],
    }

    # Search options for -L option
    $f_options = $service_options.filter |$x| { split($x,' ')[0] == '-L' }
    $log_option = $f_options[0]
    $log_dir = $f_options[1]
    if( $use_logrotate and $log_option == '-L' ) {
        ensure_resource('exec', "/bin/mkdir -p ${log_dir}")
        file { "/etc/logrotate.d/${service_name}":
            ensure  => present,
            content => template("${module_name}/logrotate.erb"),
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            require => Exec["/bin/mkdir -p ${log_dir}"]
        }
    }
}
