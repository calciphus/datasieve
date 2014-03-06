class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def flatten_with_path(obj, parent_prefix = nil)
		# If interaction contains this, stop the propogation so we don't get junk stuff (like arrays of keywords)
		killpoints = ["interaction.hashtags", "interaction.mention_ids", "interaction.mentions", "links.meta.content_type", "links.meta.keywords", "links.meta.opengraph", "links.meta.twitter", "links.retweet_count", "links.url", "links.content.entities", "salience.content.topics", "twitter.hashtags", "twitter.display_urls", "twitter.links", "twitter.mentions","twitter.mention_ids", "twitter.retweet.hashtags", "twitter.retweet.mention_ids", "twitter.retweet.mentions","salience.content.entities.themes"]
		res = {}

		obj.each_with_index do |elem, i|
		  if elem.is_a?(Array)
		    k, v = elem
		  else
		    k, v = i, elem
		  end

		  key = parent_prefix ? "#{parent_prefix}.#{k}" : k # assign key name for result hash

		  if !killpoints.include?key
		  	  if v.is_a? Enumerable
			    res.merge!(flatten_with_path(v, key)) # recursive call to flatten child elements
			  else
			    res[key] = v
			  end
		  end
		end

		res
	end
end