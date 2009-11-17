$:.unshift File.dirname(__FILE__) + '/../lib'
require 'kramdown'
require 'test/unit/assertions'
require 'yaml'

include Test::Unit::Assertions

arg = ARGV[0] || File.join(File.dirname(__FILE__), 'testcases')

arg = if File.directory?(arg)
        File.join(arg, '**/*.text')
      else
        arg + '.text'
      end

width = ((size = %x{stty size 2>/dev/null}).length > 0 ? size.split.last.to_i : 72) rescue 72
width -= 8
fwidth = 0
Dir[arg].each {|f| fwidth = [fwidth, f.length + 10].max }.each do |file|
  print(('Testing ' + file + ' ').ljust([fwidth, width].min))
  $stdout.flush

  html_file = file.sub('.text', '.html')
  opts_file = file.sub('.text', '.options')
  options = File.exist?(opts_file) ? YAML::load(File.read(opts_file)) : {}
  doc = Kramdown::Document.new(File.read(file), options)
  begin
    assert_equal(File.read(html_file), doc.to_html)
    puts 'PASSED'
  rescue Exception => e
    puts '  FAILED'
    puts $!.message if $VERBOSE
    puts $!.backtrace if $DEBUG
  end
  puts "Warnings:\n" + doc.warnings.join("\n") if !doc.warnings.empty? && $VERBOSE
end
