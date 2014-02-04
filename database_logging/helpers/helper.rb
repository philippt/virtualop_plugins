def table_names
  %w|requests command_executions command_execution_params ssh_logging text_logging|
end

def archive_dir(machine)
  config_string("archive_directory", machine.home + "/db_archive")
end