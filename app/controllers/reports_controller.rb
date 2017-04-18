class ReportsController < ApplicationController
  include Reports

  before_action :get_resource, only: %i(update destroy)

  # 日報の一覧
  def index
    respond_to do |format|
      format.json do
        date = get_date
        if date.present?
          @reports = Report.find_in_month(current_user.id, date)
        else
          @reports = Report.find_in_week(current_user.id)
        end
      end

      format.csv do
        if params.dig(:reports, :start).blank? || params.dig(:reports, :end).blank?
          redirect_to admin_csvs_path, alert: '集計開始日と集計終了日を設定してください。'
          return
        end
        start_on = Date.parse(params[:reports][:start])
        end_on = Date.parse(params[:reports][:end])
        if start_on.blank? || end_on.blank? || start_on > end_on
          redirect_to admin_csvs_path, alert: '集計開始日が集計終了日より後になっています。'
          return
        end
        @reports = Report.includes(:user).joins(:user)
          .where(worked_in: [start_on..end_on])
          .order('users.id', worked_in: :asc)
        send_data render_to_string,
                  filename: "dailyreport_#{start_on.strftime('%Y%m%d')}-#{end_on.strftime('%Y%m%d')}.csv",
                  type: :csv
      end

      format.any do
        @date = get_date || Time.zone.now.to_date
        @projects = current_user.projects.available
        # render view
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        report = current_user.reports.build(worked_in: params[:worked_in])
        params[:project_ids].each_with_index do |project_id, i|
          next if project_id.blank? || params[:workloads][i].blank?
          report.operations << Operation.new(
            project_id: project_id,
            workload: params[:workloads][i]
          )
        end
        report.save!

        render partial: 'report', locals: {
          data: {
            date: report.worked_in,
            holiday: report.worked_in.holiday?(:jp),
            report: report
          }
        }
      end
    end
  end

  def update
    authorize @report

    respond_to do |format|
      format.json do
        ops = []
        params[:operation_ids].each_with_index do |operation_id, i|
          op = Operation.find_by(id: operation_id) || Operation.new
          op.assign_attributes({
            project_id: params[:project_ids][i],
            workload: params[:workloads][i]
          })
          ops << op
        end
        @report.operations = ops
        @report.save!

        render partial: 'report', locals: {
          data: {
            date: @report.worked_in,
            holiday: @report.worked_in.holiday?(:jp),
            report: @report
          }
        }
      end
    end
  end

  def destroy
    authorize @report
  end

  private

  def get_resource
    @report = Report.find(params[:id])
  end
end
