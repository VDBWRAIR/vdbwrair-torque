class torque::mom::install inherits torque::mom {
    exec {"install_torque_mom_${torque::version}":
        command => "${torque::build_dir}/torque-package-mom-linux-x86_64.sh --install && /bin/touch ${torque::build_dir}/.torque_mom_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.torque_mom_${torque::version}_${norm_config_options}",
        require => Class['torque::build'],
        before  => Class['torque::config'],
    }

    if $with_pam { 
        exec {"install_torque_pam_${torque::version}":
            command => "${torque::build_dir}/torque-package-pam-linux-x86_64.sh --install && /bin/touch ${torque::build_dir}/.torque_pam_${torque::version}_${norm_config_options}",
            creates => "${torque::build_dir}/.torque_pam_${torque::version}_${norm_config_options}",
            require => Class['torque::build'],
            before  => Class['torque::config'],
        }
    }
    if $with_pam {
        package { ['policycoreutils','checkpolicy']:
            ensure  => 'latest'
        }
    }
    # If xauthpath specified for pbs_mom options
    if $options['xauthpath'] {
        # If --with-xauth not specified during build
        if empty($withxauth) {
            package { 'xorg-x11-xauth':
                ensure => 'latest'
            }
        }
    }
}
