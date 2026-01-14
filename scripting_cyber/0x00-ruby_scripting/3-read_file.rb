#!/usr/bin/env ruby

require 'json'

def count_user_ids(path)
  parsed = JSON.parse(File.read(path))
  user_counts = Hash.new(0)
  
  parsed.each { |item| user_counts[item['userId']] += 1 if item['userId'] }
  
  user_counts.sort.each do |user_id, count|
    puts "#{user_id}: #{count}"
  end
end
