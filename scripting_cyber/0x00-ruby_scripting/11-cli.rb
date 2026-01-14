#!/usr/bin/env ruby

require 'optparse'

TASKS_FILE = 'tasks.txt'

def load_tasks
  if File.exist?(TASKS_FILE)
    File.readlines(TASKS_FILE).map(&:chomp)
  else
    []
  end
end

def save_tasks(tasks)
  File.open(TASKS_FILE, 'w') do |file|
    tasks.each { |task| file.puts(task) }
  end
end

def add_task(task)
  tasks = load_tasks
  tasks << task
  save_tasks(tasks)
  puts "Task '#{task}' added."
end

def list_tasks
  tasks = load_tasks
  if tasks.empty?
    puts "No tasks found."
  else
    tasks.each { |task| puts task }
  end
end

def remove_task(index)
  tasks = load_tasks
  if index < 1 || index > tasks.size
    puts "Error: Invalid task index."
  else
    removed_task = tasks.delete_at(index - 1)
    save_tasks(tasks)
    puts "Task '#{removed_task}' removed."
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cli.rb [options]"

  opts.on('-a', '--add TASK', 'Add a new task') do |task|
    options[:add] = task
  end

  opts.on('-l', '--list', 'List all tasks') do
    options[:list] = true
  end

  opts.on('-r', '--remove INDEX', Integer, 'Remove a task by index') do |index|
    options[:remove] = index
  end

  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit
  end
end.parse!

if options[:add]
  add_task(options[:add])
elsif options[:list]
  list_tasks
elsif options[:remove]
  remove_task(options[:remove])
elsif ARGV.empty? && options.empty?
  puts "Usage: cli.rb [options]"
  puts "Run with -h for help."
end
