class torque::config inherits torque {
    file { "${torque::torque_home}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755'
    }

    file { "${torque::torque_home}/server_name":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => "${torque::torque_server}",
        require => File["${torque::torque_home}"]
    }

    file { "${torque_home}/pbs_environment":
        ensure  => 'present',
        content => template("${module_name}/pbs_environment.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque::torque_home}"]
    }

    file { "${torque::torque_home}/spool":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
        require => File["${torque::torque_home}"]
    }

    file { "${torque::torque_home}/undelivered":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
        require => File["${torque::torque_home}"]
    }

    file { "${torque::torque_home}/checkpoint":
        ensure => directory,
        owner => root,
        group => root,
        mode => '1777',
        require => File["${torque::torque_home}"]
    }

    file { "${torque::torque_home}/aux":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755',
        require => File["${torque::torque_home}"]
    }
}
