#
# File: tex-converter.rb
# Author: J. Carlson (jxxcarlson@gmail.com)
# Date: 9/26/2014
#
# This is a first step towards writing a LaTeX backend
# for Asciidoctor. It is based on the 
# Dan Allen's demo-converter.rb.  The "convert" method
# is unchanged, the methods "document node" and "section node" 
# have been redefined, and several new methods have been added.
#
# The main work will be in identifying asciidoc elements
# that need to be transformed and adding a method for
# each such element.  As noted below, the "warn" clause
# in the "convert" method is a useful tool for this task.
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
require_relative 'node_processors'
require_relative 'tex_block'

include TeXBlock

class LaTeXConverter
  include Asciidoctor::Converter
  register_for 'latex'
  
  
  def convert node, transform = nil
    
    node_list = %w(document section paragraph )  # top
    node_list << %w(ulist olist)                 # list
    node_list << %w(inline_quoted stem)          # block
    
    if node_list.include? node.node_name
      node.tex_process
    else
      warn %(Node to implement: #{node.node_name}).magenta
    end
    
  end

  def document node
    node.tex_process 
   end

  def section node
    node.tex_process
  end

  def paragraph node
    node.tex_process
  end
  
  def ulist node
    node.tex_process
  end
  
  def olist node
    node.tex_process
  end
  
  def inline_quoted node
    node.tex_process 
  end
    
  def stem node
    node.tex_process
  end
     
  def inline_anchor node
    node.tex_process
  end
  
  
end


=begin  
  def open node
    puts ["Node:".magenta,  "open".red, "blockname: #{node.blockname}\n".red, 
      "content: #{node.content}\n".red,
      "attributes: #{node.attributes}\n".red,
      "attr1: #{node.attributes[1]}\n".red].join(" ") if VERBOSE 
  end
=end


=begin  
  def literal node
    puts "HERE I AM!".magenta
    puts ["Node:".magenta,  "open".red, "blockname: #{node.blockname}\n".red, 
      "content: #{node.content}\n".red,
      "attributes: #{node.attributes}\n".red,
      "lines: #{node.lines}\n".red,].join(" ") if VERBOSE
      puts "node.class = #{node.class}".yellow if VERBOSE 
      node.content
  end
=end



