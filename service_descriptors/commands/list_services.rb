description "returns services that are configured to run on this machine"

param :machine

add_columns [ :name, :runlevel ]

mark_as_read_only

#include_for_crawling if @op.plugins.include? 'machine_crawler'

on_machine do |machine, params|
  machine.list_installed_services.map do |service_name|
    machine.service_details("service" => service_name)
  end
end  
