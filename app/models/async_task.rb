class AsyncTask < ApplicationRecord
  belongs_to :user

  after_initialize :set_defaults, if: :new_record?

  STATUSES = {
    pending: 'pending',
    queued: 'queued',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }.freeze

  TASK_TYPES = {
    fill_absent_reports: 'fill_absent_reports'
  }.freeze

  validates :task_type, presence: true, inclusion: { in: TASK_TYPES.values }
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(status: STATUSES[:pending]) }
  scope :processing, -> { where(status: STATUSES[:processing]) }
  scope :completed, -> { where(status: STATUSES[:completed]) }
  scope :failed, -> { where(status: STATUSES[:failed]) }

  def pending?
    status == STATUSES[:pending]
  end

  def queued?
    status == STATUSES[:queued]
  end

  def processing?
    status == STATUSES[:processing]
  end

  def completed?
    status == STATUSES[:completed]
  end

  def failed?
    status == STATUSES[:failed]
  end

  def cancelled?
    status == STATUSES[:cancelled]
  end

  def progress_percentage
    return 0 if total_items.nil? || total_items.zero?

    [(progress.to_f / total_items * 100).round, 100].min
  end

  def estimated_remaining_time
    return nil unless processing? && progress.positive? && started_at.present?

    elapsed = Time.current - started_at
    rate = progress.to_f / elapsed
    remaining_items = total_items - progress

    (remaining_items / rate).seconds
  end

  def cancellable?
    pending? || queued? || processing?
  end

  def cancel!
    return false unless cancellable?

    update!(status: STATUSES[:cancelled], completed_at: Time.current)
    broadcast_status_change
    true
  end

  def broadcast_status_change
    ActionCable.server.broadcast(
      "task_status_#{id}",
      status_payload
    )
  end

  def status_payload
    {
      type: 'status_update',
      task_id: id,
      status: status,
      progress: progress_percentage,
      total_items: total_items,
      processed_items: progress,
      estimated_remaining_seconds: estimated_remaining_time&.to_i,
      result: completed? ? result : nil,
      error: failed? ? last_error : nil,
      started_at: started_at&.iso8601,
      completed_at: completed_at&.iso8601
    }
  end

  private

  def set_defaults
    self.params ||= {}
    self.result ||= {}
  end
end
