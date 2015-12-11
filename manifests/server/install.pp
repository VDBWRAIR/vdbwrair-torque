class torque::server::install inherits torque::server {
    exec {"install_torque_server_${torque::version}":
        command => "${torque::build_dir}/torque-package-server-linux-x86_64.sh --install && touch ${torque::build_dir}/.torque_server_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.torque_server_${torque::version}_${norm_config_options}",
        require => Exec["make_packages_${torque::version}"],
        before  => Class['torque::config'],
    }
    exec {"install_torque_clients_${torque::version}":
        command => "${torque::build_dir}/torque-package-clients-linux-x86_64.sh --install && touch ${torque::build_dir}/.torque_clients_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.torque_clients_${torque::version}_${norm_config_options}",
        require => Exec["make_packages_${torque::version}"],
        before  => Class['torque::config'],
    }
}
