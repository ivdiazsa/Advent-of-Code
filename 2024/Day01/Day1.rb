#!/usr/bin/env ruby

# SETUP!

input_file = ARGV[0]

historian_lists = File.readlines(input_file, chomp: true).map do |line|
  line.split(' ').map(&:to_i)
end.transpose

historian_lists[0].sort!
historian_lists[1].sort!

# PART ONE!

total_distance = 0
for i in (0...historian_lists[0].length)
  total_distance += (historian_lists[0][i] - historian_lists[1][i]).abs()
end

puts "PART ONE: #{total_distance}"

# PART TWO!

occurrences = historian_lists[1].tally
similarity_score = 0

historian_lists[0].each do |location_id|
  unless occurrences.has_key?(location_id) then next end
  similarity_score += location_id * occurrences[location_id]
end

puts "PART TWO: #{similarity_score}"
