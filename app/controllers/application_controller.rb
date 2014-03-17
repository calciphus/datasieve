class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def is_num?(str)
	  begin
	    !!Integer(str)
	  rescue ArgumentError, TypeError
	    false
	  end
	end

	def flatten_with_path(obj, parent_prefix = nil)
		errs = []
		# If interaction contains this, stop the propogation so we don't get junk stuff (like arrays of keywords)
		killpoints = ["interaction.hashtags", "interaction.mention_ids", "interaction.mentions", "links.meta.content_type", "links.meta.keywords", "links.meta.opengraph", "links.meta.twitter", "links.retweet_count", "links.url", "links.content.entities", "salience.content.topics", "twitter.hashtags", "twitter.display_urls", "twitter.links", "twitter.mentions","twitter.mention_ids", "twitter.retweet.hashtags", "twitter.retweet.mention_ids", "twitter.retweet.mentions","salience.content.entities.themes","facebook.story_tags"]
		res = {}

		obj.each_with_index do |elem, i|
		  if elem.is_a?(Array)
		    k, v = elem
		  else
		    k, v = i, elem
		  end

		  key = parent_prefix ? "#{parent_prefix}.#{k}" : k # assign key name for result hash

		  if ( !is_num?k and !killpoints.include?key ) or k == 0
		  	  if v.is_a?(Enumerable)
			    res.merge!(flatten_with_path(v, key)) # recursive call to flatten child elements
			  else
			    res[key] = v
			  end
		  else
		  	res[parent_prefix] = v
		  	# This is an iterated array, will be caught when only one result is returned
			# Or this is one of our killpoints
			# errs <<  "#{k} :: #{v}"
		  end

		end

		puts errs

		res
	end

	def get_datatype(obj)
		if obj.is_a?String
			return "string"
		elsif obj.is_a?Fixnum or obj.is_a?Bignum
			return "int"
		elsif obj.is_a?Array
			return "array(#{get_datatype(obj[0])})"
		elsif obj.is_a?TrueClass or obj.is_a?FalseClass
			return "bool"
		elsif obj.is_a?Hash
			return "hash"
		elsif obj.is_a?NilClass
			return nil
		else
			return "#{obj.class}".downcase.gsub("class","")
		end
	end
end