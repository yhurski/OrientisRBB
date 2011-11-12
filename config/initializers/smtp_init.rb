#  ActionMailer::Base.smtp_settings = {
#      :address => Configs.find_by_name('smtp_address').value,
#      :user_name => Configs.find_by_name('smtp_username').value,
#      :password => Configs.find_by_name('smpt_password').value,
#      :authentification => :login,
 #     :enable_starttls_auto => Configs.find_by_name('smpt_ssl').value
#  }