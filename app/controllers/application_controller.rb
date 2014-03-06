class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def flatten_with_path(obj, parent_prefix = nil)
		res = {}

		obj.each_with_index do |elem, i|
		  if elem.is_a?(Array)
		    k, v = elem
		  else
		    k, v = i, elem
		  end

		  key = parent_prefix ? "#{parent_prefix}.#{k}" : k # assign key name for result hash

		  if v.is_a? Enumerable
		    res.merge!(flatten_with_path(v, key)) # recursive call to flatten child elements
		  else
		    res[key] = v
		  end
		end

		res
	end
end