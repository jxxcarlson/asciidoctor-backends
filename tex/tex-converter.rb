#
# File: tex-converter.rb
# Author: J. Carlson (jxxcarlson@gmail.com)
# Date: 9/26/2014
#
# This is a first step towards writing a LaTeX backend
# for Asciidoctor. It is based on the 
# Dan Allen's demo-converter.rb and differs
# from it only in the redefinition of the
# methods "document node" and "section node"
#
# Usage: 
#
#   $ asciidoctor -r ./tex-converter.rb -b latex sample1.ad -o sample1.tex
#
# Comments
#
#   1.  The "warn" clause in the converter code is quite useful.  
#       For example, you will discover in running the converter on 
#       "sample-1.ad" that you have not implemented code for 
#       the "olist" node. Thus you can work through ever more complex 
#       examples to discover what you need to do to increase the coverage
#       of the converter. Hackish and ad hoc, but a process nonetheless.
#
#   2.  The converter simply passes on what it does not understand, e.g.,
#       LaTeX, This is good. However, we will have to map constructs
#       like"+\( a^2 = b^2 \)+" to $ a^2 + b^2 $, etc.
#       This can be done at the preprocessor level.
#
#   3.  In view of the preceding, we may need to chain a frontend
#       (preprocessor) to the backend. In any case, the main work 
#       is in transforming Asciidoc elements to TeX elements.
#       Other than the asciidoc ->  tex mapping, the tex-converter 
#       does not need to understand tex.
#
#   4.  Included in this repo is the file "sample1.ad"
#
#
#  CURRENT STATUS
#
#  The following constructs are processed
#
#  * sections to a depth of five, e.g., == foo, === foobar, etc.
#  * ordered and unordered lists, thugh nestings is untested and
#    likely does not work.
#  * *bold* and _italic_
#  * hyperlinks like http://foo.com[Nerdy Stuff]
#


require 'asciidoctor'
require_relative 'colored_text'
require_relative 'tex_block'

include TeXBlock

class LaTeXConverter
  include Asciidoctor::Converter
  register_for 'latex'
  
  VERBOSE = true

  def convert node, transform = nil
    transform ||= node.node_name
    if respond_to? transform
      send transform, node
    else
      warn %(Node to implement: #{transform}).magenta
    end
  end

  def document node
    puts "header: #{node.header}".blue
    # puts "#{node.methods}".magenta
    # TeX Preamble and macor definitions
    doc = File.open("preamble", 'r') { |f| f.read }
    doc << File.open("macros", 'r') { |f| f.read }
    # Title, Author, Etc
    doc << "\n\n\\title\{#{node.header.title}\}\n"
    doc << "\\author\{#{node.author}\}\n"
    doc << "\\date\{#{node.revdate}\}\n\n\n"
    doc << "\n\n\\begin\{document\}\n"
    doc << "\\maketitle\n\n\n" 
      
    processed_content = TeXBlock.process_environments node.content
    doc << processed_content
    # puts node.content
    
    doc << "\n\n\\end{document}\n\n"  
   end

  def section node
    space = "-"*2*(node.level-1)
    puts ["Node:".blue, "level #{node.level}:".cyan, "#{space} #{node.title}"].join(" ") if VERBOSE
    case node.level
    when 1
       "\\section\{#{node.title}\}\n\n#{node.content}\n\n"
     when 2
       "\\subsection\{#{node.title}\}\n\n#{node.content}\n\n"
     when 3
       "\\subsubsection\{#{node.title}\}\n\n#{node.content}\n\n"
     when 4
       "\\paragraph\{#{node.title}\}\n\n#{node.content}\n\n"
     when 5
       "\\subparagraph\{#{node.title}\}\n\n#{node.content}\n\n"
     end
  end

  def paragraph node
    # node.content.tr("\n", ' ') << "\n"
    node.content << "\n\n"
  end
  
  def ulist node
    puts ["Node:".blue, "list".cyan, "#{node.content.count} items"].join(" ") if VERBOSE
   
    list = "\\begin{itemize}\n\n"
    node.content.each do |item|
      puts ["  --  item: ".blue, "#{item.text.abbreviate}"].join(" ") if VERBOSE
      list << "\\item #{item.text}\n\n"
    end
    list << "\\end{itemize}\n\n"     
  end
  
  def olist node
    puts ["Node:".blue, "list".cyan, "#{node.content.count} items"].join(" ")  if VERBOSE
   
    list = "\\begin{enumerate}\n\n"
    node.content.each do |item|
      puts ["  --  item:  ".blue, "#{item.text.abbreviate}"].join(" ") if VERBOSE
      list << "\\item #{item.text}\n\n"
    end
    list << "\\end{enumerate}\n\n"     
  end
  
  def inline_quoted node
    puts ["Node:".blue,  "inline quoted".cyan, "type[#{node.type}]: #{node.text.cyan}"].join(" ") if VERBOSE
    case node.type
    when :strong
      "\\textbf\{#{node.text}\}"
    when :emphasis
      "\\emph\{#{node.text}\}"
    else
      "\\unknown\\{#{node.text}\\}"
    end   
  end
  
  def inline_anchor node
    puts ["Node:".blue, "inline anchor".cyan,  "type[#{node.type}], ".green + " text: #{node.text} target: #{node.target}".cyan].join(" ") if VERBOSE
    case node.type
    when :link
      "\\href\{#{node.target}\}\{#{node.text}\}"
    else
      "undefined inline anchor"
    end
  end
  
  
end


