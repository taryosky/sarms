class Createstudent < ActiveRecord::Migration[5.0]
  def change
  	create_table :students  do |t|
  		t.string :matno, index: true, unique: true, null: false
  		t.string :sname, index: true, null: false
		t.string :fname, index: true, null: false
      t.string :state_of_origin
      t.string :lga
      t.string :nationality
      t.string :religion
      t.string :phone
      t.string :email
      t.integer :sex
      t.integer :level, null: false, default: 100
      t.binary :passport
  	end
  end
end