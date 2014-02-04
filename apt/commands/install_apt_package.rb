description "calls apt to install a package"

param :machine
param! "name", "the name of the package to install", :allows_multiple_values => true

display_type :list

on_machine do |machine, params|
  # TODO hardcoded sudo
  # TODO add version
  machine.ssh("command" => "sudo apt-get install -y --force-yes #{params["name"].join(" ")}")
  
  @op.without_cache do
    new_package_list = machine.list_installed_apt_packages
    # TODO check doesn't fly for multiple packages
    # installed_packages = new_package_list.select do |row|
      # row["name"] == params["name"]
    # end
    # if installed_packages.size == 0
      # raise "did not find package with name '#{params["name"]}' in list_installed_apt_packages after installation!"
    # end
  end
  
  params["name"]
end