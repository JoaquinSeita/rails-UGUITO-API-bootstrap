class ChangeTypeColumnNameInNotes < ActiveRecord::Migration[6.1]
  def change
    rename_column :notes, :type, :note_type
  end
end
