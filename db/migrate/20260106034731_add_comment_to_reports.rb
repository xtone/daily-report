class AddCommentToReports < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :comment, :text
  end
end
