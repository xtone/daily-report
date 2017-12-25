class EstimatesController < ApplicationController
  include SpreadsheetReadable

  before_action :authenticate_user!

  layout 'admin'

  def index
  end

  def confirm
    if params[:file].blank?
      fail '見積書ファイルをアップロードしてください。'
    end
    #book = Spreadsheet.open(params[:file].tempfile)
    #sheet = book.worksheets.first
    book = Roo::Spreadsheet.open(params[:file].tempfile)
    sheet = book.sheet(0)

    begin
      pj_code = read(sheet, 'AA5')
    rescue => ex
      # sheetに問題があり、valueが取得できない
      @error = 'ファイルの解析に失敗しました。'
      return
    end

    if pj_code.blank?
      fail 'PJコードが空です。'
    end
    project = Project.find_by(code: pj_code)
    if project.nil?
      fail '存在しないプロジェクトです。'
    end
    @resource = Estimate.new(
      project: project,
      subject: read(sheet, 'S7'),
      estimated_on: read(sheet, 'S3'),
      serial_no: read(sheet, 'S14'),
      amount: read(sheet, 'I14'),
      director_manday: read(sheet, 'U5', 0.0),
      engineer_manday: read(sheet, 'V5', 0.0),
      designer_manday: read(sheet, 'W5', 0.0),
      other_manday: read(sheet, 'X5', 0.0),
      cost: read(sheet, 'Z5', 0),
      filename: params[:file].original_filename
    )

    @warnings = []
    if Estimate.exists?(serial_no: @resource.serial_no)
      @warnings << '見積書NOが重複しています。登録内容は上書きされます。'
    end
    if @resource.too_old?
      @warnings << '見積もり日付が半年以上前です。'
    end
    if @resource.deja_vu?
      @warnings << '過去に全く同じ工数・原価設定があります。'
    end
    unless @resource.valid?
      fail @resource.errors.full_messages.join("\n")
    end
  rescue => ex
    @error = ex.message
  end

  def create
    resource = Estimate.find_or_initialize_by(serial_no: estimate_params[:serial_no])
    resource.assign_attributes(estimate_params)
    resource.save!
    redirect_to estimates_path, notice: "見積書ファイル #{resource.filename} を登録しました。"
  rescue => ex
    redirect_to estimates_path, alert: ex.message
  end

  private

  def estimate_params
    params.require(:estimate).permit(
      *%i(project_id subject estimated_on serial_no amount
          director_manday engineer_manday designer_manday other_manday cost filename)
    )
  end
end
