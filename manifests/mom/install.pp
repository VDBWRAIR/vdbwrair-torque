class torque::mom::install inherits torque::mom {
    exec {"install_torque_mom_${version}":
        command => "${torque::build_dir}/torque-package-mom-linux-x86_64.sh --install && touch ${torque::build_dir}/torque_mom_installed",
        creates => "${torque::build_dir}/torque_mom_installed",
        require => Class['torque::build'],
        before  => Class['torque::config'],
    }
}
