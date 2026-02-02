class TaskStatusChannel < ApplicationCable::Channel
  def subscribed
    task_id = params[:task_id]
    task = AsyncTask.find_by(id: task_id)

    if task && task.user_id == current_user.id
      stream_from "task_status_#{task_id}"
      transmit(task.status_payload)
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def request_status(data)
    task = AsyncTask.find_by(id: data['task_id'])
    return unless task && task.user_id == current_user.id

    transmit(task.status_payload)
  end
end
