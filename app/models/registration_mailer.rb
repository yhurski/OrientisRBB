class RegistrationMailer < ActionMailer::Base
  def confirm(to, site, reglink, login, pass)
    @subject = "Confirm registraion at " + site
    @recipients = to
    @from  = ActionMailer::Base.smtp_settings[:address]
    @sent_on =  Time.now.utc
      
    #view data
    @body[:reglink] = reglink
    @body[:login] = login
    @body[:passwd] = pass
  end
end
