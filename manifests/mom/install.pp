class torque::mom::install inherits torque::mom {
    exec {"install_torque_mom_${torque::version}":
        command => "${torque::build_dir}/torque-package-mom-linux-x86_64.sh --install && /bin/touch ${torque::build_dir}/.torque_mom_${torque::version}_${config_sha}",
        creates => "${torque::build_dir}/.torque_mom_${torque::version}_${config_sha}",
        require => Class['torque::build'],
        before  => Class['torque::config'],
    }

    if grep($torque::configure_options, '--with-pam') {
        exec {"install_torque_pam_${torque::version}":
            command => "${torque::build_dir}/torque-package-pam-linux-x86_64.sh --install && /bin/touch ${torque::build_dir}/.torque_pam_${torque::version}_${config_sha}",
            creates => "${torque::build_dir}/.torque_pam_${torque::version}_${config_sha}",
            require => Class['torque::build'],
            before  => Class['torque::config'],
        }
    }
}
