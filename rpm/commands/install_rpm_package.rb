description 'installs an RPM package'

param :machine
param "name", "the name of the package to install", :mandatory => true, :allows_multiple_values => true, :default_param => true

on_machine do |m, params|
  to_install = params["name"]
  m.as_user("user_name" => "root") do |machine|
    already_installed = machine.installed_rpm_package_names
    to_install.each do |name|
      if already_installed.include? name
        to_install.delete name
      end
    end
    
    if to_install.size > 0    
      command = case machine.linux_distribution.split("_").first
      when "centos"
        "yum"
      when "sles"
        "zypper"
      end      
      begin
        machine.ssh("command" => "#{command} install -y #{to_install.join(" ")}")
      rescue => detail
        if matched = /consider running yum-complete-transaction/.match(detail.message)
          machine.install_rpm_package("name" => "yum-utils")
          machine.ssh("command" => "yum-complete-transaction -y")
        else
          raise
        end
      end
      
      @op.without_cache do
        machine.list_unix_services
      end
    end
    
  end
  to_install
end
