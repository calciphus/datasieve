class MainController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:webhook]

	def index
	end

	def webhook
		if params[:token] == ENV['SIMPLE_TOKEN']
			#if params[:interactions]
				params[:interactions].each do |iac|
					output = flatten_with_path(iac.to_json)
					output.each do |i,k|
						if !i.include?"http"
							puts i.gsub(".0."," -> ").gsub(".0","").gsub("."," -> ")
						end
					end
				end
			#end
		end
		respond_to do |format|
			# Respond with success per Datasift documentation
			format.json{
				render :json => Hash["success" => true].to_json
			}
		end
	end
end
