class CreateTimeTables < ActiveRecord::Migration[5.0]
  def change
    create_table :time_tables do |t|
    	t.references :course, foreign_key: true
    	t.string :day, index: true
    	t.integer :period, index: true
    	t.string :hall, index: true
    	t.integer :row, index: true
    	
    end
  end
end
