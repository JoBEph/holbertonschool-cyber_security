#!/usr/bin/env ruby
require 'json'
require_relative '4-writefile'

def merge_json_files(file1_path, file2_path)
  data_1 = JSON.parse(File.read(file1_path))
  data_2 = JSON.parse(File.read(file2_path))
  merged_data = data_1 + data_2
  
  File.write(file2_path, JSON.pretty_generate(merged_data))
end
