# For each link in the page download the video and place it in @video_path.
def fetch_video(*args)
  options             = args.extract_options!
  link                = options[:link]
  video_path          = options[:video_path]
  domain              = options[:domain]
  video_css_selector  = options[:video_css_selector]
  video_link_text     = options[:video_link_text]
  file_downloaded     = nil
  download_link       = nil
  page_url            = "#{domain}#{link[:href]}"
  page                = Nokogiri::HTML(open(page_url))
 
  page.css(video_css_selector).each do |download_a|
    if download_a.text.downcase == video_link_text.downcase
      download_link = download_a[:href]
      file_name = download_link.split('/')[-1]
      file_path = "#{video_path}/#{file_name}"
      if not File.file?(file_path)
        file = open(download_link).read()
        File.open(file_path, 'w') {|f| f.write(file) }
        file_downloaded = file_name
      end
    end
  end
  return file_downloaded
end
