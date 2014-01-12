description "returns a slogan to be used"

execute do |params|
  slogans = @op.list_slogans
  idx = (rand() * slogans.size).to_i
  slogans[idx]['slogan']
end
