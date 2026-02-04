module SystemAdmin
  class RetirementProcessingsController < SystemAdmin::BaseController
    def index
      @users = User.available.order(:name)
    end

    def create
      target_user = User.find(params[:user_id])
      last_working_date = Date.parse(params[:last_working_date])
      retirement_date = Date.parse(params[:retirement_date])

      if last_working_date > retirement_date
        return render json: { error: '開始日は終了日より後にできません' }, status: :unprocessable_entity
      end

      task = current_user.async_tasks.create!(
        task_type: AsyncTask::TASK_TYPES[:fill_absent_reports],
        status: AsyncTask::STATUSES[:pending],
        params: {
          user_id: target_user.id,
          user_name: target_user.name,
          last_working_date: last_working_date.to_s,
          retirement_date: retirement_date.to_s
        }
      )

      FillAbsentReportsJob.perform_later(task.id)

      render json: {
        task_id: task.id,
        status: task.status,
        message: '休み一括登録を開始しました'
      }, status: :accepted
    end

    def show
      task = current_user.async_tasks.find(params[:id])

      render json: task.status_payload
    end

    def cancel
      task = current_user.async_tasks.find(params[:id])

      if task.cancel!
        render json: { message: 'タスクをキャンセルしました' }
      else
        render json: { error: 'タスクをキャンセルできません' }, status: :unprocessable_entity
      end
    end
  end
end
