class Admin::SummaryReportsController < AdminController

	def sizing_summary_pdf
		@client = current_user.user_project_setting.client
		if params[:sizing] == "compressor_sizing"
			sizing_items = @company.compressor_sizing_tags.all
		else
			sizing_items = eval("@company.#{params[:sizing]}s.all")
		end

		html = render_to_string(:partial => "admin/#{params[:sizing]}s/#{params[:sizing]}_summary.html.erb", 
								:layout => false,
							    :locals => {"#{params[:sizing]}s".to_sym => sizing_items, :client => @client})

		file_name = "#{params[:sizing]}s_summary_#{Time.now.to_i}.pdf"
		kit = PDFKit.new("<html><body>"+html+"</body></html>")
		kit.stylesheets << "#{Rails.root}/public/stylesheets/bootstrap.css" 
		kit.stylesheets << "#{Rails.root}/public/stylesheets/application.css" 
		kit.stylesheets << "#{Rails.root}/public/javascripts/tablecloth/tablecloth.css" 
		send_data(kit.to_pdf, :filename => file_name, :type => "application/pdf")
	end
end
