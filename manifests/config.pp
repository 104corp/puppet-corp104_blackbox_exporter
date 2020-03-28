class blackbox::config {

  file { $config_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => $config_mode,
    content => template('prometheus/blackbox_exporter.yaml.erb'),
    notify  => $notify_service,
  }
}
