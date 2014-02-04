def point_or_null(line, ts)
  point = line.select { |x| x[0] == ts }.first
  if point
    puts "found #{Time.at(point[0])}"
    point
  else
    puts "nilling for #{Time.at(ts)}"
    [ ts, 0 ]
  end
end