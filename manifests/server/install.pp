class torque::server::install inherits torque::server {
    exec {"install_torque_server_${torque::version}":
        command => "${torque::build_dir}/torque-package-server-linux-x86_64.sh --install && touch ${torque::build_dir}/torque_server_installed",
        creates => "${torque::build_dir}/torque_server_installed",
        require => Exec["make_packages_${torque::version}"]
    }
    exec {"install_torque_clients_${torque::version}":
        command => "${torque::build_dir}/torque-package-clients-linux-x86_64.sh --install && touch ${torque::build_dir}/torque_clients_installed",
        creates => "${torque::build_dir}/torque_clients_installed",
        require => Exec["make_packages_${torque::version}"]
    }
}
