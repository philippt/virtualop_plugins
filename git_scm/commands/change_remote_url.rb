description "deletes a remote and adds it with a new URL"

param :machine
param! :working_copy
param :remote
param! "url", "the new URL for the remote"

on_machine do |machine, params|
  machine.delete_remote("working_copy" => params["working_copy"], "remote" => params["remote"])
  machine.add_remote("working_copy" => params["working_copy"], "remote" => params["remote"], "url" => params["url"])
end
