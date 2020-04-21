class corp104_blackbox_exporter::config (
  String $monitor_type,
) inherits corp104_blackbox_exporter {
  File {
    owner   => 'root',
    group   => 'root',
    require => Class['corp104_blackbox_exporter::install'],
    notify  => Class['corp104_blackbox_exporter::service']
  }

  file { "${corp104_blackbox_exporter::config_path}":
    ensure  => file,
    content => template("${module_name}/blackbox_exporter.yaml.erb"),
  }

}
