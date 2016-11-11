class ReportsController < ApplicationController
  before_action :authenticate_user!

  # 日報の一覧
  def index
    respond_to do |format|
      format.csv do
        @reports = Operation.where(worked_in: [params[:start]..params[:end]])
      end
    end
  end
end
