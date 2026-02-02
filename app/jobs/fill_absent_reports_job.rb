class FillAbsentReportsJob < ApplicationJob
  queue_as :default

  PROGRESS_UPDATE_INTERVAL = 1

  def perform(task_id)
    @task = AsyncTask.find(task_id)

    return if @task.cancelled?

    begin
      target_user = User.find(@task.params['user_id'])
      last_working_date = Date.parse(@task.params['last_working_date'])
      retirement_date = Date.parse(@task.params['retirement_date'])

      business_days = calculate_business_days(last_working_date + 1.day, retirement_date)

      @task.update!(
        status: AsyncTask::STATUSES[:processing],
        started_at: Time.current,
        total_items: business_days.count
      )
      @task.broadcast_status_change

      process_business_days(target_user, business_days)

      @task.update!(
        status: AsyncTask::STATUSES[:completed],
        completed_at: Time.current,
        progress: business_days.count,
        result: {
          created_reports_count: business_days.count,
          target_user_name: target_user.name,
          date_range: "#{(last_working_date + 1.day).strftime('%Y/%m/%d')} - #{retirement_date.strftime('%Y/%m/%d')}"
        }
      )
      @task.broadcast_status_change

    rescue StandardError => e
      handle_error(e)
      raise
    end
  end

  private

  def calculate_business_days(start_date, end_date)
    (start_date..end_date).reject do |date|
      date.saturday? || date.sunday? || date.holiday?(:jp)
    end
  end

  def process_business_days(target_user, business_days)
    absent_project = Project.find_by(name: '休み')
    raise '休みプロジェクトが見つかりません' if absent_project.nil?

    processed = 0

    business_days.each do |date|
      @task.reload
      break if @task.cancelled?

      create_absent_report(target_user, absent_project, date)
      processed += 1

      update_progress(processed) if should_update_progress?(processed)
    end
  end

  def create_absent_report(target_user, absent_project, date)
    existing_report = target_user.reports.find_by(worked_in: date)
    return if existing_report.present?

    report = target_user.reports.create!(worked_in: date)
    report.operations.create!(project: absent_project, workload: 100)
  end

  def should_update_progress?(processed)
    (processed % PROGRESS_UPDATE_INTERVAL).zero?
  end

  def update_progress(processed)
    @task.update!(progress: processed)
    @task.broadcast_status_change
  end

  def handle_error(error)
    @task.update!(
      status: AsyncTask::STATUSES[:failed],
      completed_at: Time.current,
      last_error: "#{error.class}: #{error.message}"
    )
    @task.broadcast_status_change
  end
end
