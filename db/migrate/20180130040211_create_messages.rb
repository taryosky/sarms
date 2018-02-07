class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
	  t.string :title
	  t.string :content
	  t.string :sender_id
	  t.date :date
    end
  end
end
