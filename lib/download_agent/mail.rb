require 'rubygems'
require 'action_mailer'
require 'active_support'
require 'yaml'

sample_email_config_data = <<EOS
:mail:  # Parameters for GMail or Google Apps for your Domain
  :smtp_server: smtp.gmail.com
  :smtp_port: 587
  :domain: example.com
  :user_name: john@example.com
  :password: secretpassword
  :authentication: plain
  :enable_starttls_auto: true
EOS

agent_dir = ::File.expand_path(::File.join(ENV['HOME'], '.download_agent'))
email_config_file = ::File.expand_path(
  ::File.join(agent_dir,'/video-agent-email.yml'))

if not File.file?(email_config_file)
  # Write out a sample config file for the user to fill in.
  File.open(email_config_file, 'w') {|f| f.write(sample_email_config_data) }
  puts "Wrote a sample configuration to #{email_config_file}."
  puts "Please edit it to tailor it to your requirements"
  exit!
else
  raw_config = File.read(email_config_file)
  EMAIL_CONFIG = YAML.load(raw_config)
end

# ActionMailer parameters for GMail or Google Apps for your Domain
ActionMailer::Base.smtp_settings = {
  :address              => EMAIL_CONFIG[:mail][:smtp_server],
  :port                 => EMAIL_CONFIG[:mail][:smtp_port],
  :domain               => EMAIL_CONFIG[:mail][:domain],
  :user_name            => EMAIL_CONFIG[:mail][:user_name],
  :password             => EMAIL_CONFIG[:mail][:password],
  :authentication       => EMAIL_CONFIG[:mail][:authentication],
  :enable_starttls_auto => EMAIL_CONFIG[:mail][:enable_starttls_auto]
}

# Setup the mailer we want to use.
class VideoMailer < ActionMailer::Base
  default :from => ::EMAIL_CONFIG[:mail][:user_name]

  def new_video(*args)
    options     = args.extract_options!
    message     = options[:message]
    app_config  = options[:app_config]
    date        = Time.new.strftime("%Y-%m-%d")
    to          = app_config[:general][:mail_to]
    title       = app_config[:general][:email_title]
    mail(:to      => to, 
         :subject => "[#{title}] Videos for #{date}", 
         :body    => message
        )
  end
end
