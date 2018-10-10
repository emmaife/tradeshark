module ApplicationHelper
	def current_class(path)
    	return 'active' if current_page?(path) 
    	''
	end
	
end
