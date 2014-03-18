class MainController < ApplicationController
	skip_before_filter :verify_authenticity_token, :only => [:webhook]

	def index
		@elements = DsElement.all.order(:fullpath)
		respond_to do |format|
			# Respond with success per Datasift documentation
			format.html {}
			format.json{
				output = Hash["elements" => []]
				@elements.each do |e|
					thise = Hash["source" => e.fullpath.split(".")[0], "field" => e.prop,  "namespace" => e.fullpath, "datatype" => e.datatype, "first_appeared" => e.created_at, "last_seen" => e.updated_at]
					output["elements"] << thise
				end
				render :json => output.to_json
			}
		end
	end

	# Plain text output
	def plain
		@elements = DsElement.all.order(:fullpath)
		respond_to do |format|
			# Respond with success per Datasift documentation
			format.html {
				output = []
				@elements.each do |e|
					output << e.fullpath.gsub(/\.$/,'')
				end
				render :text => output.join("<br>")
			}
		end
	end

	# CSV output
	def csv
		@elements = DsElement.all.order(:fullpath)
		respond_to do |format|
			# Respond with success per Datasift documentation
			format.csv {
				output = ["fullpath,datatype,first_seen,last_seen"]
				@elements.each do |e|
					output << "#{e.fullpath.gsub(/\.$/,'')},#{e.datatype},#{e.created_at},#{e.updated_at}"
				end
				response.headers['Content-Type'] = 'text/csv'
			    response.headers['Content-Disposition'] = 'attachment; filename=sieve_export.csv'    
				render :text => output.join("\n")
			}
		end
	end

	# JSON output
	def json
		@elements = DsElement.all.order(:fullpath)
		# Respond with success per Datasift documentation
		output = Hash["elements" => []]
		@elements.each do |e|
			thise = Hash["source" => e.fullpath.split(".")[0], "field" => e.prop,  "namespace" => e.fullpath, "datatype" => e.datatype, "first_appeared" => e.created_at, "last_seen" => e.updated_at]
			output["elements"] << thise
		end
		render :json => output.to_json
	end

	def webhook
		#if params[:token] == ENV['SIMPLE_TOKEN']
			if params[:interactions]
				params[:interactions].each do |iac|
					output = flatten_with_path(iac)
					#puts output.to_yaml
					output.each do |i, v|
						puts "#{i} : #{v} (#{get_datatype(v)})"
						if !i.include?"http"
							target = i
							#target = i.gsub(".0",".").gsub("..",".")
							elem = DsElement.find_or_create_by(fullpath: target)
							if elem.prop == nil
								elem.prop = target.split(".")[-1]
							end
							if elem.datatype == nil or elem.datatype == ""
								elem.datatype = get_datatype(v) #rescue nil
							end
							if elem.changed?
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
