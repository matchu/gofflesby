#!/usr/bin/ruby
require 'fileutils'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.data = {}

opts = OptionParser.new
opts.banner = "Usage: add_test.rb [names] [options]"

opts.on('-e', '-y', '--edit', 'Edit files on creation') do
  options.edit = true
end

opts.on('-n', '--no-edit', 'Skip editor prompts') do
  options.edit = false
end

opts.on('--in=MANDATORY', 'Input for test') do |data|
  options.data[:in] = data
end

opts.on('--out=MANDATORY', 'Output for test') do |data|
  options.data[:out] = data
end

opts.parse!

ANSWERS = {
  'y' => true,
  'n' => false,
  '' => true
}
ANSWERS_STR = '[Yn]'

if ARGV.empty?
  puts opts.help
else
  ARGV.each do |name|
    dirname = File.join('tests', name)
    begin
      FileUtils.mkdir(dirname)
    rescue
      puts "Could not create directory: #{$!}"
    else
      puts "Created directory #{dirname}"
      [:in, :out].each do |name|
        filename = File.join(dirname, "#{name.to_s}.txt")
        if options.data[name]
          File.open(filename, 'w') { |f| f.write(options.data[name]) }
          puts "Wrote #{filename}"
        else
          should_edit = options.edit
          if should_edit == false
            FileUtils.touch(filename)
            puts "Created #{filename}"
          end
          while should_edit.nil?
            print "Edit #{filename}? #{ANSWERS_STR}"
            answer = STDIN.gets.chomp
            should_edit = ANSWERS[answer]
          end
          system('editor', filename) if should_edit
        end
      end
    end
  end
end
