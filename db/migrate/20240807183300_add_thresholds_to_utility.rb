class AddThresholdsToUtility < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :thresholds, :jsonb, default: {}
  end
end
