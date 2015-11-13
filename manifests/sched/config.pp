class torque::sched::config inherits torque::sched {
    file { "${torque::torque_home}/sched_priv":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0750',
        require => Class['torque::server::install']
    }

    file { "${torque::torque_home}/sched_logs":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0750',
    }

    file { "${torque::torque_home}/sched_priv/accounting":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File["${torque::torque_home}/sched_priv"]
    }

    file { "${torque::torque_home}/sched_priv/dedicated_time":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque::torque_home}/sched_priv"]
    }
    file { "${torque::torque_home}/sched_priv/holidays":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque::torque_home}/sched_priv"]
    }
    file { "${torque::torque_home}/sched_priv/resource_group":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque::torque_home}/sched_priv"]
    }
    file { "${torque::torque_home}/sched_priv/sched_config":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["${torque::torque_home}/sched_priv"]
    }
}
