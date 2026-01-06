module SystemAdmin
  class BillsController < SystemAdmin::BaseController
    include SpreadsheetReadable

    before_action :set_bill, only: %i[show edit update destroy]

    def index
      @bills = Bill.includes(estimate: :project)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)

      @bills = @bills.where('subject LIKE ?', "%#{params[:q]}%") if params[:q].present?

      return if params[:estimate_id].blank?

      @bills = @bills.where(estimate_id: params[:estimate_id])
    end

    def show
      @estimate = @bill.estimate
    end

    def new
      @bill = Bill.new
    end

    def edit
      @estimates = Estimate.includes(:project).order(created_at: :desc)
    end

    # uc-16: 請求書アップロード確認
    def confirm
      raise I18n.t('system_admin.bills.upload.file_required') if params[:file].blank?

      book = Roo::Spreadsheet.open(params[:file].tempfile)
      sheet = book.sheet('設定')
      @estimate_serial_no = read(sheet, 'C8')
      estimate = Estimate.find_by(serial_no: @estimate_serial_no)
      raise I18n.t('system_admin.bills.upload.estimate_not_found') if estimate.blank?

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
      if Bill.exists?(serial_no: @resource.serial_no)
        @warnings << I18n.t('system_admin.bills.upload.duplicate_serial_no')
      end
      raise @resource.errors.full_messages.join("\n") unless @resource.valid?
    rescue StandardError => e
      @error = e.message
    end

    def create
      resource = Bill.find_or_initialize_by(serial_no: bill_params[:serial_no])
      resource.assign_attributes(bill_params)
      resource.save!
      redirect_to system_admin_bills_path, notice: I18n.t('system_admin.bills.created', filename: resource.filename)
    rescue StandardError => e
      redirect_to new_system_admin_bill_path, alert: e.message
    end

    def update
      if @bill.update(bill_params)
        redirect_to system_admin_bill_path(@bill), notice: I18n.t('system_admin.bills.updated')
      else
        @estimates = Estimate.includes(:project).order(created_at: :desc)
        render :edit
      end
    end

    def destroy
      estimate = @bill.estimate
      @bill.destroy
      redirect_to system_admin_bills_path(estimate_id: estimate&.id), notice: I18n.t('system_admin.bills.deleted')
    end

    private

    def set_bill
      @bill = Bill.find(params[:id])
    end

    def bill_params
      params.expect(
        bill: %i[estimate_id serial_no subject amount filename claimed_on]
      )
    end
  end
end
