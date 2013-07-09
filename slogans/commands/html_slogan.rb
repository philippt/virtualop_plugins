description "returns a slogan to be used"

execute do |params|
  slogans = @op.list_slogans
  idx = (rand() * slogans.size).to_i
  slogan = slogans[idx]
  if slogan.has_key? 'alternative_html'
    slogan['alternative_html']
  else
    slogan['slogan']
  end
end
