class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_resource, only: %i(update destroy)

  # 日報の一覧
  def index
    respond_to do |format|
      format.json do
        if params[:date].present?
          @reports = Report.find_in_month(current_user.id, get_date)
        else
          @reports = Report.find_in_week(current_user.id)
        end
      end

      format.csv do
        raise ActiveRecord::RecordNotFound if params[:reports][:start].blank? || params[:reports][:end].blank?
        @reports = Report.includes(:user).joins(:user)
          .where(worked_in: [params[:reports][:start]..params[:reports][:end]])
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

  # 集計
  def summary
    authorize Report.new
    if params[:reports].present?
      @date_start = params_to_date(:reports, :start)
      @date_end = params_to_date(:reports, :end)
      @sum = Operation.summary(@date_start, @date_end)
      @projects = Project.where(id: @sum.map{ |s| s[0] }).order(:id).index_by(&:id)
      @users = Report.submitted_users(@date_start, @date_end).order(:id)
      if params[:csv].present?
        send_data render_to_string(template: 'reports/summary.csv.ruby'), filename: "summary_#{Time.zone.now.strftime('%Y%m%d')}.csv", type: :csv
        return
      end
    else
      @date_start = Time.zone.now.to_date << 1
      @date_end = Time.zone.now.to_date
    end
  end

  # 未提出一覧
  def unsubmitted
    authorize Report.new
    if params[:reports].present?
      @date_start = params_to_date(:reports, :start)
      @date_end = params_to_date(:reports, :end)
      @data = []
      User.available.each do |user|
        dates = Report.unsubmitted(user.id, @date_start, @date_end)
        if dates.present?
          @data << {
            user: user,
            dates: dates
          }
        end
      end
    else
      @date_start = Time.zone.now.to_date << 1
      @date_end = Time.zone.now.to_date
    end
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

  def params_to_date(object_name, method)
    Date.new(
      params[object_name]["#{method}(1i)"].to_i,
      params[object_name]["#{method}(2i)"].to_i,
      params[object_name]["#{method}(3i)"].to_i
    )
  end
end
