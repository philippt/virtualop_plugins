description "calls zypper refresh and uses expect to confirm a new key to be used for verifying a repo"

param :machine

on_machine do |machine, params|
  expect_file = 'tmp/zypper_refresh.exp'
  expect_script = read_local_template(:expect, binding())
  machine.write_file('target_filename' => expect_file, 'content' => expect_script)
  
  machine.ssh("expect #{expect_file}")
end
