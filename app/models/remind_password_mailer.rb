class RemindPasswordMailer < ActionMailer::Base
  def email(to, site, loglink, passwd)
    @subject = "Password recovering at " + site
    @recipients = to
    @from  = ActionMailer::Base.smtp_settings[:address]
    @sent_on =  Time.now.utc
    
    @body[:loglink] = loglink
    @body[:passwd] = passwd
  end
end
