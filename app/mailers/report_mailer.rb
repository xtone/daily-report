class ReportMailer < ApplicationMailer
  def unsubmitted_notification(user, dates)
    @user = user
    @dates = dates
    @site_url = 'http://daily-report.kibihara-dev.xtone.local/'
    mail(to: user.email, subject: "【日報未提出通知】#{user.name}_#{Time.zone.now.strftime('%Y/%m/%d')}")
  end
end
