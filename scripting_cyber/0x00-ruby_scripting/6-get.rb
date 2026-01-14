#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def get_request(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  
  puts "Response status: #{response.code} #{response.message}"
  
  if response.is_a?(Net::HTTPSuccess)
    puts "Response body:"
    data = JSON.parse(response.body)
    puts JSON.pretty_generate(data)
  else
    puts "Failed to retrieve data"
  end
end
