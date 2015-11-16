# batchversion.rb
# Original credit goes to https://github.com/HEP-Puppet/torque
# which has no License
Facter.add(:batchversion) do
  confine :osfamily => 'RedHat'
  setcode do
  	Facter::Util::Resolution::exec('rpm -q --qf "%{VERSION}\n" torque')
  end
end
