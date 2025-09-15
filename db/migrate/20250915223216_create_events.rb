class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :location
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "open"

      t.timestamps
    end
  end
end
