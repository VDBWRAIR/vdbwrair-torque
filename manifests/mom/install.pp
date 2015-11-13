class torque::mom::install inherits torque::mom {
    exec {"install_torque_mom_${version}":
        command => "${build_dir}/torque-package-mom-linux-x86_64.sh --install && touch ${build_dir}/torque_mom_installed",
        creates => "${build_dir}/torque_mom_installed",
        require => Exec["make_packages_${version}"]
    }
}
