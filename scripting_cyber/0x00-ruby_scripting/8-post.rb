#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def post_request(url, body_params = {})
  uri = URI.parse(url)

  request = Net::HTTP::Post.new(uri)
  request.content_type = 'application/json'
  request.body = body_params.to_json unless body_params.empty?

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
    http.request(request)
  end

  status_code = response.code
  status_message = response.message
  puts "Response status: #{status_code} #{status_message}"
  
  if response.code.to_i >= 200 && response.code.to_i < 300
    puts "Response body:"
    data = JSON.parse(response.body)
    puts JSON.pretty_generate(data)
  else
    puts "Failed to post data"
  end
end
