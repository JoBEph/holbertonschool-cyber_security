#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def get_request(url)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  
  status_code = response.code
  status_message = response.message
  puts "Response status: #{status_code} #{status_message}"
  
  if response.code.to_i >= 200 && response.code.to_i < 300
    puts "Response body:"
    data = JSON.parse(response.body)
    puts JSON.pretty_generate(data)
  else
    puts "Failed to retrieve data"
  end
end
