class torque::build inherits torque {
    if $configure_options {
        $config_options = join($torque::configure_options, " ")
    } else {
        $config_options = ""
    }
    $norm_config_options = regsubst($config_options, "[^\w]|_", "", "G")

    if grep($torque::configure_options, '--with-pam') {
        $with_pam = true
    } else {
        $with_pam = false
    }

    case $::osfamily {
        'RedHat': {
            $dev_packages = [
                'openssl-devel', 'libxml2-devel', 'boost-devel',
                'gcc', 'gcc-c++', 'hwloc', 'hwloc-devel', 'pam-devel',
                'wget'
            ]
        }
        default: {
            fail("Module ${module_name} is not supported on ${::osfamily}")
        }
    }
    ensure_packages($dev_packages)

    file {"${torque::build_dir}/uninstall.sh":
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0750',
        content => template('torque/uninstall.sh.erb')
    }

    if grep($torque::configure_options, '--with-xauth') {
        $withxauth = true
        package { "xorg-x11-xauth":
            ensure  => present,
            before  => Exec["configure_${torque::version}"]
        }
    }

    exec {"download_src_${torque::version}":
        command => "/usr/bin/wget ${torque::download_url} -O- | /bin/tar xzvf -",
        creates => "${torque::build_dir}/INSTALL",
        cwd => dirname($torque::build_dir)
    }
    file { $build_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        require => Exec["download_src_${torque::version}"]
    }
    exec {"configure_${torque::version}":
        command => "${torque::build_dir}/configure ${config_options} && /bin/touch ${torque::build_dir}/.configure_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.configure_${torque::version}_${norm_config_options}",
        cwd => $torque::build_dir,
        require => Exec["download_src_${torque::version}"],
        notify  => Exec["make_${torque::version}"]
    }
    exec {"make_${torque::version}":
        command => "/usr/bin/make && /bin/touch ${torque::build_dir}/.make_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.make_${torque::version}_${norm_config_options}",
        cwd => $torque::build_dir,
        require => Exec["configure_${torque::version}"],
        notify  => Exec["make_packages_${torque::version}"]
    }

    exec {"make_packages_${torque::version}":
        command => "/usr/bin/make packages && /bin/touch ${torque::build_dir}/.make_packages_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.make_packages_${torque::version}_${norm_config_options}",
        cwd => $torque::build_dir,
        require => Exec["make_${torque::version}"]
    }
    exec {"install_torque_docs_${torque::version}":
        command => "${torque::build_dir}/torque-package-doc-linux-x86_64.sh --install && /bin/touch ${torque::build_dir}/.torque_docs_${torque::version}_${norm_config_options}",
        creates => "${torque::build_dir}/.torque_docs_${torque::version}_${norm_config_options}",
        require => Exec["make_packages_${torque::version}"],
    }
}
