module SystemAdmin
  class ReportsController < SystemAdmin::BaseController
    before_action :set_report, only: %i[show edit update destroy]

    def index
      @reports = Report.includes(:user, operations: :project)
                       .order(worked_in: :desc)
                       .page(params[:page])
                       .per(20)

      @reports = @reports.where(user_id: params[:user_id]) if params[:user_id].present?

      @reports = @reports.where(worked_in: (params[:date_from])..) if params[:date_from].present?

      return if params[:date_to].blank?

      @reports = @reports.where(worked_in: ..(params[:date_to]))
    end

    # uc-5: 日報サマリー表示
    def summary
      @end_date = params.dig(:reports, :end).present? ? Date.parse(params[:reports][:end]) : Time.zone.today
      @start_date = params.dig(:reports, :start).present? ? Date.parse(params[:reports][:start]) : (@end_date << 1)

      if @start_date > @end_date
        flash.now[:alert] = I18n.t('system_admin.reports.summary.invalid_date_range')
        return
      end

      if params.dig(:reports, :start).present?
        @sum = Operation.summary(@start_date, @end_date)
        @projects = Project.where(id: @sum.keys).order(:id).index_by(&:id)
        @users = Report.submitted_users(@start_date, @end_date).order(:id)
      end

      respond_to do |format|
        format.html
        format.csv do
          if @sum.nil?
            redirect_to summary_system_admin_reports_path, alert: I18n.t('system_admin.reports.summary.select_period')
            return
          end
          send_data render_to_string,
                    filename: "summary_#{@start_date.strftime('%Y%m%d')}-#{@end_date.strftime('%Y%m%d')}.csv",
                    type: :csv
        end
      end
    end

    # uc-6: 未提出日報確認
    def unsubmitted
      @end_date = params.dig(:reports, :end).present? ? Date.parse(params[:reports][:end]) : Time.zone.today
      @start_date = params.dig(:reports, :start).present? ? Date.parse(params[:reports][:start]) : (@end_date << 1)

      if @start_date > @end_date
        flash.now[:alert] = I18n.t('system_admin.reports.unsubmitted.invalid_date_range')
        return
      end

      return if params.dig(:reports, :start).blank?

      @data = []
      User.available.order(:name).each do |user|
        dates = Report.unsubmitted_dates(user.id, start_on: @start_date, end_on: @end_date)
        @data << { user: user, dates: dates } if dates.present?
      end
    end

    def show
      @operations = @report.operations.includes(:project)
    end

    def edit
      @operations = @report.operations.includes(:project)
      @projects = Project.available.order_by_reading
    end

    def update
      if @report.update(report_params)
        redirect_to system_admin_report_path(@report), notice: I18n.t('system_admin.reports.updated')
      else
        @operations = @report.operations.includes(:project)
        @projects = Project.available.order_by_reading
        render :edit
      end
    end

    def destroy
      user = @report.user
      @report.destroy
      redirect_to system_admin_reports_path(user_id: user.id), notice: I18n.t('system_admin.reports.deleted')
    end

    private

    def set_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.expect(report: %i[worked_in comment])
    end
  end
end
