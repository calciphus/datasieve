class MainController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:webhook]

	def index
		@elements = DsElement.all.order(:fullpath)
	end

	def webhook
		#if params[:token] == ENV['SIMPLE_TOKEN']
			if params[:interactions]
				params[:interactions].each do |iac|
					output = flatten_with_path(iac)
					output.each do |i,k|
						if !i.include?"http"
							target = i.gsub(".0",".").gsub("..",".")
							elem = DsElement.find_or_create_by(fullpath: target)
							if elem.prop == nil
								elem.prop = target.split(".")[-1]
								elem.save
							else
								elem.touch
							end
						end
					end
				end
			end
		#end
		respond_to do |format|
			# Respond with success per Datasift documentation
			format.json{
				render :json => Hash["success" => true].to_json
			}
		end
	end
end
