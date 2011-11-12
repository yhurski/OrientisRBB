class ChangeEmailMailer < ActionMailer::Base

  def confirm(to, site, confirm_link, login)
    @subject = "Change e-mail at " + site
    @recipients = to
    @from = ActionMailer::Base.smtp_settings[:address]
    @sent_on = Time.now.utc
      
    @body[:confirm_link] = confirm_link
    @body[:login] = login
    @body[:site] = site
  end

end
