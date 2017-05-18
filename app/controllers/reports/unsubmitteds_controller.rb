class Reports::UnsubmittedsController < ApplicationController
  include Reports

  layout 'admin'

  # 日報未提出一覧
  def show
    authorize Report.new, :unsubmitted?
    if params[:reports].present?
      @start_date = Date.parse(params[:reports][:start])
      @end_date = Date.parse(params[:reports][:end])
      if @start_date > @end_date
        flash.now[:alert] = '集計開始日が集計終了日より後になっています。'
        return
      end
      @data = []
      User.available.each do |user|
        dates = Report.unsubmitted_dates(user.id, @start_date, @end_date)
        @data << { user: user, dates: dates } if dates.present?
      end
    else
      @start_date = Time.zone.now.to_date << 1
      @end_date = Time.zone.now.to_date
    end
  end
end