class Reports::SummariesController < ApplicationController
  include Reports
  layout 'admin'

  def show
    authorize Report.new, :summary?
    respond_to do |format|
      format.csv do
        raise ActiveRecord::RecordNotFoundunless unless params[:reports].present?
        @date_start = params_to_date(:reports, :start)
        @date_end = params_to_date(:reports, :end)
        if @date_start > @date_end
          redirect_to summary_path, alert: '集計開始日が集計終了日より後になっています。'
          return
        end
        @sum = Operation.summary(@date_start, @date_end)
        @projects = Project.where(id: @sum.map{ |s| s[0] }).order(:id).index_by(&:id)
        @users = Report.submitted_users(@date_start, @date_end).order(:id)
        send_data render_to_string,
                  filename: "summary_#{@date_start.strftime('%Y%m%d')}-#{@date_end.strftime('%Y%m%d')}.csv",
                  type: :csv
      end
      format.any do
        if params[:reports].present?
          @date_start = params_to_date(:reports, :start)
          @date_end = params_to_date(:reports, :end)
          if @date_start > @date_end
            flash.now[:alert] = '集計開始日が集計終了日より後になっています。'
            return
          end
          @sum = Operation.summary(@date_start, @date_end)
          @projects = Project.where(id: @sum.map{ |s| s[0] }).order(:id).index_by(&:id)
          @users = Report.submitted_users(@date_start, @date_end).order(:id)
        else
          @date_end = Time.zone.now.to_date
          @date_start = @date_end << 1
        end
      end
    end
  end
end