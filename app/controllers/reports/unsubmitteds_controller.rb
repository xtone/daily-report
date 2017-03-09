class Reports::UnsubmittedsController < ApplicationController
  include Reports

  layout 'admin'

  # 日報未提出一覧
  def show
    authorize Report.new, :unsubmitted?
    if params[:reports].present?
      @date_start = params_to_date(:reports, :start)
      @date_end = params_to_date(:reports, :end)
      if @date_start > @date_end
        flash.now[:alert] = '集計開始日が集計終了日より後になっています。'
        return
      end
      @data = []
      User.available.each do |user|
        dates = Report.unsubmitted_dates(user.id, @date_start, @date_end)
        @data << { user: user, dates: dates } if dates.present?
      end
    else
      @date_start = Time.zone.now.to_date << 1
      @date_end = Time.zone.now.to_date
    end
  end
end