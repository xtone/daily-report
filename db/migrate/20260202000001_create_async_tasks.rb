class CreateAsyncTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :async_tasks do |t|
      t.references :user, null: false, foreign_key: true, type: :integer
      t.string :task_type, null: false
      t.string :status, null: false, default: 'pending'
      t.integer :progress, default: 0
      t.integer :total_items
      t.json :params
      t.json :result
      t.text :last_error
      t.integer :retry_count, default: 0
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps

      t.index %i[user_id status]
      t.index %i[task_type status]
      t.index :created_at
    end
  end
end
