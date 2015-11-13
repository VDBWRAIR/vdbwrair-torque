# Base class inherited by all others
#  - validates args
#  - provides args to other classes through inheritance
class torque (
    $version            = $torque::params::version,
    $build_dir          = $torque::params::build_dir,
    $torque_home        = $torque::params::torque_home,
    $install_prefix     = $torque::params::install_prefix,
    $configure_options  = $torque::params::configure_options,
    $torque_base_url    = $torque::params::torque_base_url,
    $pbs_environment    = $torque::params::pbs_environment,
) inherits torque::params {
    include stdlib

    $full_version = "torque-${version}"
    $download_file = "${full_version}.tar.gz"
    $download_url = "${torque_base_url}/${download_file}"

    validate_string($version)
    validate_absolute_path($build_dir)
    validate_absolute_path($torque_home)
    validate_absolute_path($install_prefix)
    validate_array($configure_options)
    validate_string($torque_base_url)
    validate_cmd(
        $download_url,
        "curl -sI '%' | grep -q '200 OK'",
        "${download_url} is not a valid url"
    )
    validate_array($pbs_environment)
}
