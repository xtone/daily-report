class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.references :user
      t.date :worked_in

      t.timestamps
    end
  end
end
