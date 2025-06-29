class BillsController < ApplicationController
  include SpreadsheetReadable

  before_action :authenticate_user!

  layout 'admin'

  def index; end

  def confirm
    raise '見積書ファイルをアップロードしてください。' if params[:file].blank?

    book = Roo::Spreadsheet.open(params[:file].tempfile)
    sheet = book.sheet('設定')
    @estimate_serial_no = read(sheet, 'C8')
    logger.debug "estimate_serial_no: #{@estimate_serial_no}"
    estimate = Estimate.find_by(serial_no: @estimate_serial_no)
    raise '紐づく見積書が存在しません。' unless estimate.present?

    serial_no = read(sheet, 'C15')
    claimed_on = read(sheet, 'C13')

    sheet = book.sheet('請求書')
    @tax_included_amount = read(sheet, 'I14', 0)

    @resource = Bill.new(
      estimate: estimate,
      serial_no: serial_no,
      subject: read(sheet, 'F12'),
      claimed_on: claimed_on,
      amount: (@tax_included_amount / (1.0 + AppSettings.consumption_tax_rate)).ceil,
      filename: params[:file].original_filename
    )

    @warnings = []
    @warnings << '請求書NOが重複しています。登録内容は上書きされます。' if Bill.exists?(serial_no: @resource.serial_no)
    raise @resource.errors.full_messages.join("\n") unless @resource.valid?
  rescue StandardError => e
    @error = e.message
  end

  def create
    resource = Bill.find_or_initialize_by(serial_no: bill_params[:serial_no])
    resource.assign_attributes(bill_params)
    resource.save!
    redirect_to bills_path, notice: "請求書ファイル #{resource.filename} を登録しました。"
  rescue StandardError => e
    redirect_to bills_path, alert: e.message
  end

  private

  def bill_params
    params.require(:bill).permit(
      *%i[estimate_id claimed_on serial_no subject amount filename]
    )
  end
end
