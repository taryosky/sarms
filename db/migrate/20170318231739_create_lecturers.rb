class CreateLecturers < ActiveRecord::Migration[5.0]
  def change
    create_table :lecturers do |t|
		  t.string :title, index: true
    	t.string :staff_id, index: true, unique: true, null: false
  		t.string :sname, index: true, null: false
  		t.string :fname, index: true, null: false
      t.integer :sex
      t.string :state_of_origin
  		t.string :lga
      t.string :nationality
      t.string :religion
      t.string :phone
      t.string :email
      t.binary :passport
    end
  end
end
