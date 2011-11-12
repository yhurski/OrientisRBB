class ReportMailer < ActionMailer::Base
  def email(by, to, report, host)
    @subject = 'New report by ' + by + ' at ' + Time.now.utc.to_s
    @recipients = to
    @from  = ActionMailer::Base.smtp_settings[:address]
    
    @body[:report] = report
    @body[:host] = host
  end
end
