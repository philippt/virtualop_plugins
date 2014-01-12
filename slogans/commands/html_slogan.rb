description "returns a slogan to be used"

execute do |params|
  slogans = @op.list_slogans
  if slogans.size > 0
    idx = (rand() * slogans.size).to_i
    slogan = slogans[idx]
    if slogan
      if slogan.has_key? 'alternative_html'
        slogan['alternative_html']
      else
        slogan['slogan']
      end
    end
  else
    ''
  end
end
