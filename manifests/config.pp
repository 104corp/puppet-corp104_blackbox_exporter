class blackbox::config {

  file { $config_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => $config_mode,
    content => template('corp104_blackbox_exporter/blackbox_exporter.yaml.erb'),
#    notify  => $notify_service,
  }
}
