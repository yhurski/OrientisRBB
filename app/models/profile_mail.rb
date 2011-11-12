class ProfileMail < ActionMailer::Base
  def email(to, from, body, subj, send_time)
    @subject = subj
    @recipients = to
    @from  = from
    @sent_time =  send_time
      
    #view data
    @body[:email_text] = body
  end
end
