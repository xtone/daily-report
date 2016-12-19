class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(update destroy)

  # 日報の一覧
  def index
    respond_to do |format|
      format.json do
        date = get_date
        @reports = Report.find_in_month(current_user.id, date)
      end

      format.csv do
        raise ActiveRecord::RecordNotFound if params[:start].blank? || params[:end].blank?
        @reports = Report.includes(:user).joins(:user)
          .where(worked_in: [params[:start]..params[:end]])
          .order('users.id', worked_in: :asc)
        send_data render_to_string, filename: "dailyreport_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
      end

      format.any do
        @date = get_date
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

  def get_date
    if params[:date].present?
      time = /\A(\d{4})(\d{2})\Z/.match(params[:date]) { |m| Time.zone.local(m[1], m[2]) } || Time.zone.now
    else
      time = Time.zone.now
    end
    time.to_date
  end

  def get_resource
    @report = Report.find(params[:id])
  end
end
