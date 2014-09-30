require_relative 'colored_text'

VERBOSE=true
QUIET=false

class Asciidoctor::Document
  
  def tex_process
    puts "Node: #{self.class}".blue if VERBOSE
    # puts "Attributes: #{self.attributes}".yellow
    # puts "#{self.methods}".magenta
    doc = "%% Preamble %%\n"
    doc << File.open("preamble", 'r') { |f| f.read }
    doc << "%% Asciidoc TeX Macros %%\n"
    doc << File.open("asciidoc_tex_macros", 'r') { |f| f.read }
    doc << "%% User Macros %%\n"
    doc << File.open("macros", 'r') { |f| f.read }
    doc << "%% Front Matter %%"
    doc << "\n\n\\title\{#{self.doctitle}\}\n"
    doc << "\\author\{#{self.author}\}\n"
    doc << "\\date\{#{self.revdate}\}\n\n\n"
    doc << "%% Begin Document %%"
    doc << "\n\n\\begin\{document\}\n"
    doc << "\\maketitle\n"
    if self.attributes["toc"]
      doc << "\\tableofcontents\n"
    end
    doc << "%% Begin Document Text %%\n"
      
    processed_content = TeXBlock.process_environments self.content
    doc << processed_content
    # puts self.content
    
    doc << "\n\n\\end{document}\n\n" 
  end 
  
end


class Asciidoctor::Section
 
  def tex_process
    puts ["Node:".blue, "section[#{self.level}]:".cyan, "#{self.title}"].join(" ") if VERBOSE
    case self.level
    when 1
       "\\section\{#{self.title}\}\n\n#{self.content}\n\n"
     when 2
       "\\subsection\{#{self.title}\}\n\n#{self.content}\n\n"
     when 3
       "\\subsubsection\{#{self.title}\}\n\n#{self.content}\n\n"
     when 4
       "\\paragraph\{#{self.title}\}\n\n#{self.content}\n\n"
     when 5
       "\\subparagraph\{#{self.title}\}\n\n#{self.content}\n\n"
     end  
  end
 
end


class Asciidoctor::List
  
  
  def ulist_process
    list = "\\begin{itemize}\n\n"
    self.content.each do |item|
      puts ["  --  item: ".blue, "#{item.text.abbreviate}"].join(" ") if VERBOSE
      list << "\\item #{item.text}\n\n"
      list << item.content
    end
    list << "\\end{itemize}\n\n"  
  end
  
  def olist_process
    list = "\\begin{enumerate}\n\n"
    self.content.each do |item|
      puts ["  --  item:  ".blue, "#{item.text.abbreviate}"].join(" ") if VERBOSE
      list << "\\item #{item.text}\n\n"
      list << item.content
    end
    list << "\\end{enumerate}\n\n"  
  end
  
  def tex_process
   puts ["Node:".blue, "#{self.node_name}[#{self.level}]".cyan, "#{self.content.count} items"].join(" ") if VERBOSE
   case self.node_name
   when 'ulist'
     ulist_process
   when 'olist'
     olist_process
   else
     puts "This Asciidoctor::List, tex_process.  I don't know how to do that (#{self.node_name})" unless QUIET
   end
  end 
  
end



class Asciidoctor::Block
  
  def tex_process
    puts ["Node:".blue , "#{self.blockname}".blue].join(" ") if VERBOSE
    case self.blockname
    when :paragraph
      paragraph_process
    when :stem
      stem_process
    when :admonition
      admonition_process
    when :page_break
      page_break_process
    when :literal
      self.literal_process
    when :pass
      self.pass_process
    else
      puts "This is Asciidoctor::Block, tex_process.  I don't know how to do that (#{self.blockname})" unless QUIET
      ""
    end  
  end 
  
  def paragraph_process
    self.content << "\n\n"
  end
  
  def stem_process
    puts ["Node:".blue, "#{self.blockname}".cyan].join(" ") if VERBOSE 
    environment = TeXBlock.environment_type self.content
    if TeXBlock::INNER_TYPES.include? environment
      "\\\[\n#{self.content}\n\\\]\n"
    else
      self.content
    end
  end
  
  def admonition_process
    puts ["Node:".blue, "#{self.blockname}".cyan, "#{self.style}:".magenta, "#{self.lines[0]}"].join(" ") if VERBOSE   
    "\\admonition\{#{self.style}\}\{#{self.content}\}\n"
  end
  
  def page_break_process
    puts ["Node:".blue, "#{self.blockname}".cyan].join(" ") if VERBOSE
    "\n\\vfill\\eject\n"
  end
  
  def literal_process
    puts ["Node:".magenta, "#{self.blockname}".cyan].join(" ") if VERBOSE
    "\\begin\{verbatim\}\n#{self.content}\n\\end\{verbatim\}\n"
  end
  
  def pass_process
    puts ["Node:".magenta, "#{self.blockname}".cyan].join(" ") if VERBOSE
    self.content
  end
  
end


class Asciidoctor::Inline
  
  def tex_process
    case self.node_name
    when 'inline_quoted'
      self.inline_quoted_process
    when 'inline_anchor'
      self.inline_anchor_process
    when 'inline_break'
      self.inline_break_process
    else
      puts "This is Asciidoctor::Inline, tex_process.  I don't know how to do that (#{self.node_name})" unless QUIET
      ""
    end  
  end 
  
  def inline_quoted_process
    puts ["Node:".blue, "#{self.node_name}".cyan,  "type[#{self.type}], ".green + " text: #{self.text}"].join(" ") if VERBOSE 
    case self.type
    when :strong
      "\\textbf\{#{self.text}\}"
    when :emphasis
      "\\emph\{#{self.text}\}"
    when :asciimath
      "\$#{self.text}\$"
    when :monospaced
      "\{\\tt #{self.text}\}"
    when :unquoted
      role = self.attributes["role"]
      puts "  --  role = #{role}".yellow if VERBOSE
      if role == "red"
        "\\rolered\{ #{self.text}\}"
      else
        puts "This is inline_quoted_process.  I don't understand role = #{role}" unless QUIET
      end
    else
      "\\unknown\\{#{self.text}\\}"
    end 
  end
  
  def inline_anchor_process
    puts ["Node:".blue, "#{self.node_name}".cyan,  "type[#{self.type}], ".green + " text: #{self.text} target: #{self.target}".cyan].join(" ") if VERBOSE
    # puts "self.class = #{class}".yellow if VERBOSE
    case self.type
    when :link
      "\\href\{#{self.target}\}\{#{self.text}\}"
    when :ref
      "\\label\{#{self.text.gsub(/\[(.*?)\]/, "\\1")}\}"
    when :xref
      "\\ref\{#{self.target.gsub('#','')}\}"
    else
      puts "!!  : undefined inline anchor -----------".magenta unless QUIET
    end
  end
  
  def inline_break_process
    puts ["Node:".blue, "#{self.node_name}".cyan,  "type[#{self.type}], ".green + " text: #{self.text}"].join(" ") if VERBOSE
    "#{self.text} \\\\"
  end
  
end

