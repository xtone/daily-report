module SystemAdmin
  class EstimatesController < SystemAdmin::BaseController
    include SpreadsheetReadable

    before_action :set_estimate, only: %i[show edit update destroy]

    def index
      @estimates = Estimate.includes(:project, :bill)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)

      @estimates = @estimates.where(project_id: params[:project_id]) if params[:project_id].present?
      @estimates = @estimates.where('subject LIKE ?', "%#{params[:q]}%") if params[:q].present?
    end

    def show
      @bill = @estimate.bill
    end

    def new
      @estimate = Estimate.new
    end

    def edit
      @projects = Project.available.order_by_reading
    end

    # uc-15: 見積書アップロード確認
    def confirm
      raise I18n.t('system_admin.estimates.upload.file_required') if params[:file].blank?

      book = Roo::Spreadsheet.open(params[:file].tempfile)
      sheet = book.sheet(0)

      begin
        pj_code = read(sheet, 'AA5')
      rescue StandardError
        @error = I18n.t('system_admin.estimates.upload.parse_error')
        return
      end

      raise I18n.t('system_admin.estimates.upload.empty_project_code') if pj_code.blank?

      project = Project.find_by(code: pj_code)
      raise I18n.t('system_admin.estimates.upload.project_not_found') if project.nil?

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
        @warnings << I18n.t('system_admin.estimates.upload.duplicate_serial_no')
      end
      @warnings << I18n.t('system_admin.estimates.upload.too_old') if @resource.too_old?
      @warnings << I18n.t('system_admin.estimates.upload.deja_vu') if @resource.deja_vu?
      raise @resource.errors.full_messages.join("\n") unless @resource.valid?
    rescue StandardError => e
      @error = e.message
    end

    def create
      resource = Estimate.find_or_initialize_by(serial_no: estimate_params[:serial_no])
      resource.assign_attributes(estimate_params)
      resource.save!
      redirect_to system_admin_estimates_path,
                  notice: I18n.t('system_admin.estimates.created', filename: resource.filename)
    rescue StandardError => e
      redirect_to new_system_admin_estimate_path, alert: e.message
    end

    def update
      if @estimate.update(estimate_params)
        redirect_to system_admin_estimate_path(@estimate), notice: I18n.t('system_admin.estimates.updated')
      else
        @projects = Project.available.order_by_reading
        render :edit
      end
    end

    def destroy
      project = @estimate.project
      @estimate.destroy
      redirect_to system_admin_estimates_path(project_id: project&.id), notice: I18n.t('system_admin.estimates.deleted')
    end

    private

    def set_estimate
      @estimate = Estimate.find(params[:id])
    end

    def estimate_params
      params.expect(
        estimate: %i[project_id subject serial_no amount filename
                     estimated_on director_manday engineer_manday
                     designer_manday other_manday cost]
      )
    end
  end
end
