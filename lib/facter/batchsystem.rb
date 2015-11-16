# batchsystem.rb
# Original credit goes to https://github.com/HEP-Puppet/torque
# which has no License
Facter.add(:batchsystem) do
  confine :osfamily => 'RedHat'
  setcode do
  	Facter::Util::Resolution::exec('rpm -q --qf "%{NAME}\n" torque')
  end
end
