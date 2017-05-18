class Reports::SummariesController < ApplicationController
  include Reports
  layout 'admin'

  # 稼働集計表示＆CSVダウンロード
  def show
    authorize Report.new, :summary?
    respond_to do |format|
      format.csv do
        raise ActiveRecord::RecordNotFoundunless unless params[:reports].present?
        @start_date = Date.parse(params[:reports][:start])
        @end_date = Date.parse(params[:reports][:end])
        if @start_date > @end_date
          redirect_to summary_path, alert: '集計開始日が集計終了日より後になっています。'
          return
        end
        @sum = Operation.summary(@start_date, @end_date)
        @projects = Project.where(id: @sum.map{ |s| s[0] }).order(:id).index_by(&:id)
        @users = Report.submitted_users(@start_date, @end_date).order(:id)
        send_data render_to_string,
                  filename: "summary_#{@start_date.strftime('%Y%m%d')}-#{@end_date.strftime('%Y%m%d')}.csv",
                  type: :csv
      end
      format.any do
        if params[:reports].present?
          @start_date = Date.parse(params[:reports][:start])
          @end_date = Date.parse(params[:reports][:end])
          if @start_date > @end_date
            flash.now[:alert] = '集計開始日が集計終了日より後になっています。'
            return
          end
          @sum = Operation.summary(@start_date, @end_date)
          @projects = Project.where(id: @sum.map{ |s| s[0] }).order(:id).index_by(&:id)
          @users = Report.submitted_users(@start_date, @end_date).order(:id)
        else
          @end_date = Time.zone.now.to_date
          @start_date = @end_date << 1
        end
      end
    end
  end
end
