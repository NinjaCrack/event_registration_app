class CreateRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :registrations do |t|
      t.string :attendee_name
      t.string :attendee_email
      t.references :event, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
    add_index :registrations, [:event_id, :attendee_email], unique: true
  end
end
