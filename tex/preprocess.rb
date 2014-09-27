require '/Users/carlson/Dropbox/prog/git/asciidoctor-backends/tex/tex_block/'
include TeXBlock


base_name = ARGV[0]
input_file = base_name + ".in"
output_file = base_name + "out"



input = File.open(input_file, 'r') { |f| f.read }

puts "input:"
puts "-----------------"
puts input
puts "-----------------\n\n"

output = TeXBlock.process_environments input 

puts "output:"
puts "-----------------"
puts output
puts "-----------------\n\n"

# File.open(output_file, 'w') {|f| f.write(output) }
