class CreateColors < ActiveRecord::Migration[8.0]
  def change
    create_table :colors, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.string :color_code, null: false

      t.timestamps
    end
  end
end
