#!/usr/bin/ruby
require 'fileutils'
require 'net/http'
require 'ostruct'
require 'tempfile'
require 'uri'
require 'yaml'

class String
  def path_extension
    self.split('.').last
  end
end

class Tempfile
  def make_tmpname(basename, n)
    extension = basename.path_extension
    sprintf('%s%d-%d', basename, $$, n) + ".#{extension}"
  end
end

DIVIDER = '------------------------------'

config = OpenStruct.new(YAML.load_file('config.yml'))

if ARGV.empty?
  puts "Usage: test.rb [scripts]"
else
  begin
    ARGV.each do |script|
      if script.match(/\[(.+?)\]\.([a-z]+)/)
        uri = URI.parse($1)
        extension = $2
        tmp_script = Tempfile.new("gofflesby_script.#{extension}")
        Net::HTTP.start(uri.host) { |http|
          resp = http.get(uri.path)
          tmp_script.write(resp.body)
        }
        tmp_script.close
        script_path = tmp_script.path
      else
        script_path = File.join('scripts', script)
        raise ArgumentError, "#{script_path} does not exist" unless File.exists?(script_path)
        extension = script.path_extension
      end
      procedure = config.procedures[extension].gsub '{SCRIPT}', script_path
      raise ArgumentError, "Filetype .#{extension} unrecognized" unless procedure
      catch(:test_failed) do
        Dir.glob('tests/*').each do |test|
          Tempfile.open('gofflesby_outfile') do |outfile|
            infile = File.join(test, 'in.txt')
            desired_outfile = File.join(test, 'out.txt')
            cmd = procedure.gsub '{IO}', "< #{infile} > #{outfile.path}"
            if system(cmd)
              output = outfile.read.chomp
              desired_output = File.read(desired_outfile).chomp
              unless output == desired_output
                puts "#{test} failed", DIVIDER, 'Desired output:', desired_output,
                  DIVIDER, 'Output:', output
                throw :test_failed
              end
            else
              throw :test_failed
            end
            puts "#{test} passed"
          end
        end
      end
      tmp_script.unlink if tmp_script
    end
  rescue ArgumentError
    puts "Error: #{$!}"
  end
end
