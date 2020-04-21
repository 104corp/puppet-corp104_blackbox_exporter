class corp104_blackbox_exporter::config (
  String $monitor_type,
) inherits corp104_blackbox_exporter {
  File {
    owner   => 'root',
    group   => 'root',
    require => Class['corp104_blackbox_exporter::install'],
    notify  => Class['corp104_blackbox_exporter::service']
  }

  if "${corp104_blackbox_exporter::config_dir}" {
    file { "${corp104_blackbox_exporter::config_dir}":
      ensure => directory,
      before => File["${config_path}"].
    }
  }

  file { $config_path:
    ensure  => file,
    content => template("${module_name}/blackbox_exporter.yaml.erb"),
    require => File["${corp104_blackbox_exporter::config_dir}"],
  }

}
