class torque::config inherits torque {
    file {"${torque::torque_home}/server_name":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => "${torque_server}"
    }

    file { "${torque_home}/pbs_environment":
        ensure  => 'present',
        content => template("${module_name}/pbs_environment.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }
}
