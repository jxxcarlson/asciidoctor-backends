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
#   4.  Included in this repo are the files "sample1.ad", "sample2.ad",
#       and "elliptic.ad" which can be used to test the code
#
#   5.  Beginning with version 0.0.2 we use a new dispatch mechanism
#       which should permit one to better manage growth of the code
#       as the coverage of the converter increases. Briefly, the 
#       main convert method, whose duty is to process nodes, looks
#       at node.node_name, then makes the method call node.tex_process
#       if the node_name is registered in NODE_TYPES. The method
#       tex_process is defined by extending the various classes to
#       which the node might belong, e.g., Asciidoctor::Block,
#       Asciidoctor::Inline, etc.  See the file "node_processor.rb",
#       where these extensions are housed for the time being.
#
#       If node.node_name is not found in NODE_TYPES, then
#       a warning message is issued.  We can use it as a clue
#       to find what to do to handle this node.  All the code
#       in "node_processors.rb" was written using this hackish process.
#
#
#  CURRENT STATUS
#
#  The following constructs are processed
#
#  * sections to a depth of five, e.g., == foo, === foobar, etc.
#  * ordered and unordered lists, though nestings is untested and
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
  
  NODE_TYPES = %w(document section               \          # top
  ulist olist                                    \          # ::List
  inline_quoted inline_anchor inline_break       \          # ::Inline
  paragraph stem admonition page_break literal)             # ::Block
  
  def convert node, transform = nil
        
    if NODE_TYPES.include? node.node_name
      node.tex_process
    else
      warn %(Node to implement: #{node.node_name}, class = #{node.class}).magenta
    end
    
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



