class ReportMailer < ApplicationMailer
  # 日報未提出者にメールを送信する
  # @param [User] user
  # @param [Array] date 日付文字列の配列
  def unsubmitted_notification(user, dates)
    @user = user
    @dates = dates
    @site_url = 'http://daily-report.kibihara-dev.xtone.local/'
    mail(to: user.email, subject: "【日報未提出通知】#{user.name}_#{Time.zone.now.strftime('%Y/%m/%d')}")
  end
end
