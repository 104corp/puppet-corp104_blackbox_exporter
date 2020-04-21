class corp104_blackbox_exporter::install inherits corp104_blackbox_exporter {

  $options = "-scrape_uri=\"${corp104_blackbox_exporter::scrape_uri}\" ${corp104_blackbox_exporter::extra_options}"
  $os_arch = $facts['architecture'] ? {
    'i386'   => '386',
    'x86_64' => 'amd64',
    'amd64'  => 'amd64',
    default  => 'amd64',
  }

  # install
  case $corp104_blackbox_exporter::install_method {
    'url': {
      archive { "/tmp/${corp104_blackbox_exporter::package_name}-${corp104_blackbox_exporter::version}.tar.gz":
        ensure          => present,
        extract         => true,
        extract_path    => '/opt',
        source          => $corp104_blackbox_exporter::download_url,
        checksum_verify => false,
        creates         => "/opt/${corp104_blackbox_exporter::package_name}-${corp104_blackbox_exporter::version}.linux-${os_arch}/${corp104_blackbox_exporter::package_name}",
        cleanup         => true,
        proxy_server    => $corp104_blackbox_exporter::http_proxy,
      }

      file { "/opt/${corp104_blackbox_exporter::package_name}-${corp104_blackbox_exporter::version}.linux-${os_arch}/${corp104_blackbox_exporter::package_name}":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555',
      }
     -> file { "${corp104_blackbox_exporter::bin_dir}/${corp104_blackbox_exporter::service_name}":
          ensure => link,
          notify => Service['blackbox-exporter'],
          target => "/opt/${corp104_blackbox_exporter::package_name}-${corp104_blackbox_exporter::version}.linux-${os_arch}/${corp104_blackbox_exporter::package_name}",
          before => Systemd::Unit_file["${corp104_blackbox_exporter::service_name}.service"],
      }
    }
    'package': {
      package { $corp104_blackbox_exporter::package_name:
        ensure => $corp104_blackbox_exporter::package_ensure,
      }
      if $corp104_blackbox_exporter::manage_user {
        User[$corp104_blackbox_exporter::user] -> Package[$corp104_blackbox_exporter::package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${corp104_blackbox_exporter::install_method} is invalid")
    }
  }

  # manage user and group
  if $corp104_blackbox_exporter::manage_user {
    ensure_resource ('user', [ $corp104_blackbox_exporter::user ], {
      ensure => 'present',
      system => true,
      groups => $corp104_blackbox_exporter::extra_groups,
    })

    if $corp104_blackbox_exporter::manage_group {
      Group[$corp104_blackbox_exporter::group] -> User[$corp104_blackbox_exporter::user]
    }
  }
  if $corp104_blackbox_exporter::manage_group {
    ensure_resource ('group', [ $corp104_blackbox_exporter::group ], {
      ensure => 'present',
      system => true,
    })
  }

  # manage init type
  if $corp104_blackbox_exporter::init_style {
    case $corp104_blackbox_exporter::init_style {
      'upstart' : {
        file { "/etc/init/${corp104_blackbox_exporter::package_name}.conf":
          mode    => '0444',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.upstart.erb"),
          notify  => Service['blackbox-exporter'],
        }
        file { "/etc/init.d/${corp104_blackbox_exporter::package_name}":
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        include 'systemd'
        systemd::unit_file {"${corp104_blackbox_exporter::service_name}.service":
          content => template("${module_name}/daemon.systemd.erb"),
          notify  => Service['blackbox-exporter'],
          require => File["${corp104_blackbox_exporter::bin_dir}/${corp104_blackbox_exporter::service_name}"],
          fail => ("systemd")
        }
      }
      'sysv' : {
        file { "/etc/init.d/${corp104_blackbox_exporter::service_name}":
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.sysv.erb"),
          notify  => Service['blackbox-exporter'],
        }
      }
      'redhat' : {
        if $facts['os']['family'] == 'RedHat' {
          if $facts['os']['release']['major'] == '5' {
            file { "/etc/init.d/${corp104_blackbox_exporter::service_name}":
              mode    => '0555',
              owner   => 'root',
              group   => 'root',
              content => template("${module_name}/daemon.sysv.bash3.erb"),
              notify  => Service['blackbox-exporter'],
            }
          }
          else {
            file { "/etc/init.d/${corp104_blackbox_exporter::service_name}":
              mode    => '0555',
              owner   => 'root',
              group   => 'root',
              content => template("${module_name}/daemon.sysv.erb"),
              notify  => Service['blackbox-exporter'],
            }
          }
        }
      }
      'debian' : {
        file { "/etc/init.d/${corp104_blackbox_exporter::service_name}":
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          content => template("${module_name}/daemon.debian.erb"),
          notify  => Service['blackbox-exporter'],
        }
      }
      default : {
        fail("I don't know how to create an init script for style ${corp104_blackbox_exporter::init_style}")
      }
    }
  }

  if $corp104_blackbox_exporter::env_file_path != undef {
    file { "${corp104_blackbox_exporter::env_file_path}/${corp104_blackbox_exporter::service_name}":
      mode    => '0644',
      owner   => 'root',
      group   => '0', # Darwin uses wheel
      content => template("${module_name}/daemon.env.erb"),
      notify  => Service['blackbox-exporter'],
    }
  }

}
