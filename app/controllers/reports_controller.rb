class ReportsController < ApplicationController
  before_action :authenticate_user!

  # 日報の一覧
  def index
    respond_to do |format|
      format.html do
        if params[:date].present?
          @date = /\A(\d{4})(\d{2})\Z/.match(params[:date]) { |m| Date.new(m[1], m[2]) } ||
            Time.zone.now.beginning_of_month
        else
          @date = Time.zone.now.beginning_of_month
        end

      end
      format.csv do
        raise ActiveRecord::RecordNotFound if params[:start].blank? || params[:end].blank?
        @reports = Report.includes(:user).joins(:user)
          .where(worked_in: [params[:start]..params[:end]])
          .order('users.id', worked_in: :asc)
        send_data render_to_string, filename: "dailyreport_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end
    end
  end
end
