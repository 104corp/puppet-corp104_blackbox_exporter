class corp104_blackbox_exporter::config (
  String $monitor_type,
  String $config_dir,
  String $config_path,
) inherits corp104_blackbox_exporter {
  $config_path = "${config_dir}/${corp104_blackbox_exporter::service_yaml}"
  File {
    owner   => 'root',
    group   => 'root',
    require => Class['corp104_blackbox_exporter::install'],
    notify  => Class['corp104_blackbox_exporter::service']
  }

  if $config_dir {
    file { "${config_dir}":
      ensure => directory,
      before => File["${config_path}"],
    }
  }

  file { $config_path:
    ensure  => file,
    content => template("${module_name}/blackbox_exporter.yaml.erb"),
    require => File["${config_dir}"],
  }

}
