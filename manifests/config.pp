class corp104_blackbox_exporter::config inherits corp104_blackbox_exporter {
  File {
    owner   => 'root',
    group   => 'root',
    require => Class['corp104_blackbox_exporter::install'],
    notify  => Class['corp104_blackbox_exporter::service']
  }

  file { $corp104_blackbox_exporter::blackbox_exporter_yml:
    ensure  => file,
    content => template('corp104_blackbox_exporter/blackbox_exporter.yaml.erb'),
  }
}
