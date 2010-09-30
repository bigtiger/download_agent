module Recipe
  def process(*args)
  
    options = args.extract_options!
    recipe = options[:recipe]
    raw_config = File.read(recipe)
    app_config = YAML.load(raw_config)
  	video_name                  = app_config[:general][:email_title]
  	domain                      = app_config[:general][:domain]
  	video_css_selector          = app_config[:general][:video_css_selector]
  	archive_page_css_selector   = app_config[:general][:video_css_selector]
  	video_link_text             = app_config[:general][:video_link_text]
  	archive_url                 = app_config[:general][:video_archive_url]
  	archive_page_css_selector   = app_config[:general][:archive_page_css_selector]
  	video_path                  = ENV['HOME'] + "/Videos/#{video_name}"
  	files_downloaded            = [] 
  	
  	# Make sure that the video path exists.  If not make it.
  	Dir.mkdir(video_path) unless File::directory?(video_path)
  
  	puts "Processing for #{video_name}"
  	archive = Nokogiri::HTML(open(archive_url))
  	archive.css(archive_page_css_selector).each do |link|
  	  file_name = fetch_video :link                => link,
  	                          :video_path          => video_path, 
  	                          :domain              => domain, 
  	                          :video_css_selector  => video_css_selector,
  	                          :video_link_text     => video_link_text
  	
  	  if not file_name.nil?
  	    files_downloaded.push file_name
  	  end
  	end
  	
  	puts files_downloaded 
  	puts "Sending EMail"
  	
  	# Mail the user something to tell them what was done.
  	if files_downloaded
  	  downloaded_list_as_string = files_downloaded.join("\n")
  	  message = <<EOS 
  Hello Master,
  
  Files Downloaded: #{files_downloaded.count}
  #{downloaded_list_as_string}
  
  Thank you!
  
  Your Agent
EOS
  	
  	else
  	  message = <<EOS
  Hello Master,
  
  No new files today.
  
  Thank you
  
  Your Agent
EOS
  	
  	end
  	
  	VideoMailer.new_video(:message => message, :app_config => app_config).deliver
  	puts "Complete"
  end
  module_function :process
end
