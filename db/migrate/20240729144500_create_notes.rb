class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.string :content, null: false
      t.string :note_type, null: false
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
