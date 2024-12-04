#!/usr/bin/env ruby

data = File.open(ARGV[0]).readlines.map(&:chomp)
matches = data[0].scan(/mul\([0-9]+,[0-9]+\)/)
indexes = data[0].enum_for(:scan, /mul\([0-9]+,[0-9]+\)/).map { Regexp.last_match.begin(0) }

dos = data[0].scan(/do\(\)/)
dos_indexes = data[0].enum_for(:scan, /do\(\)/).map { Regexp.last_match.begin(0) }

donts = data[0].scan(/don't\(\)/)
donts_indexes = data[0].enum_for(:scan, /don't\(\)/).map { Regexp.last_match.begin(0) }

matches.zip(indexes).each { |m, i| p "#{i} - #{m}" }
puts ''
dos.zip(dos_indexes).each { |m, i| p "#{i} - #{m}" }
puts ''
donts.zip(donts_indexes).each { |m, i| p "#{i} - #{m}" }
