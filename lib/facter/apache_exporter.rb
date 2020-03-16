# Make blackbox exporter version available as a fact

Facter.add(:blackbox_exporter) do
  confine { Facter.value(:kernel) != 'windows' }
  confine { Facter.value(:operatingsystem) != 'nexus' }
  setcode do
    if Facter::Util::Resolution.which('blackbox-exporter')
      Facter::Core::Execution.exec('blackbox-exporter -version 2>&1').match(/^blackbox_exporter\, version (\d+.\d+.\d+).*$/)[1]
    end
  end
end
