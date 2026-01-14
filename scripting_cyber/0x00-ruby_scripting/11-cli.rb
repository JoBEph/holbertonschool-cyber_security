#!/usr/bin/env ruby

require 'optparse'

TASKS_FILE = 'tasks.txt'

def process_argv(option)
  case option
  when "-h", "--help"
    puts "Usage: cli.rb [options]"
    puts "-a, --add TASK                   Add a new task"
    puts "-l, --list                       List all tasks"
    puts "-r, --remove INDEX               Remove a task by index"
    puts "-h, --help                       Show help"
    exit
  when "-a", "--add"
    task = ARGV[1]
    if task
      File.open(TASKS_FILE, 'a') { |file| file.puts(task) }
      puts "Task '#{task}' added."
    else
      puts "Error: No task provided to add."
    end
  when "-l", "--list"
    if File.exist?(TASKS_FILE)
      tasks = File.readlines(TASKS_FILE, chomp: true)
      if tasks.empty?
        puts "No tasks found."
      else
        tasks.each { |task| puts task }
      end
    else
      puts "No tasks found."
    end
  when "-r", "--remove"
    index = ARGV[1]
    if index
      if File.exist?(TASKS_FILE)
        tasks = File.readlines(TASKS_FILE, chomp: true)
        index_num = index.to_i
        if index_num > 0 && index_num <= tasks.length
          removed_task = tasks.delete_at(index_num - 1)
          File.write(TASKS_FILE, tasks.join("\n") + (tasks.empty? ? "" : "\n"))
          puts "Task '#{removed_task}' removed."
        else
          puts "Error: Invalid index."
        end
      else
        puts "No tasks found."
      end
    else
      puts "Error: No index provided to remove."
    end
  else
    puts "Unknown option: #{option}"
    puts "Use -h or --help for usage information."
  end
end

if ARGV.empty?
  puts "Use -h or --help for usage information."
else
  process_argv(ARGV[0])
end
