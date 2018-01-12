class CreateTimeTables < ActiveRecord::Migration[5.0]
  def change
    create_table :time_tables do |t|
    	t.references :course, foreign_key: true
    	t.integer :period, index: true
    	t.string :day, index: true
    end
  end
end
