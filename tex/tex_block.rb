module TeXBlock

	def TeXBlock.get_tex_blocks str
	  rx = /\\\[(.*?)\\\]/m
	  matches = str.scan rx
	  matches.captures
	end

	def TeXBlock.get_tex_blocks str
	  rx_tex_block = /(\\\[)(.*?)(\\\])/m
	  matches = str.scan rx_tex_block
	end

	def TeXBlock.environment_type str
	  rx_env_block = /\\begin\{(.*?)\}/
	  m = str.match rx_env_block 
    if m
      env_type = m[1]
    else
      env_type = 'none'
    end
    env_type
	end

	def TeXBlock.environmemt_type_of_match m
	  environment_type m[1]
	end
  
	def TeXBlock.restore_match_data m
	  m.join()
	end

	def TeXBlock.strip_match_data m
	  m[1]
	end

	def TeXBlock.process_environments str
	  tbs = get_tex_blocks str
	  tbs.each do |tb|
	    str = TeXBlock.process_tex_block tb, str
	  end
	  str
	end
 
	 def TeXBlock.process_tex_block m, str
	   block_type = TeXBlock.environmemt_type_of_match m
	   if INNER_TYPES.include? block_type
       output = str
     else
	     output = str.gsub TeXBlock.restore_match_data(m), TeXBlock.strip_match_data(m)
	   end
	   output
	 end
 
	 INNER_TYPES = ["array", "matrix","none"]
 
end
