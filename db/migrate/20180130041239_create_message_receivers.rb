class CreateMessageReceivers < ActiveRecord::Migration[5.0]
  def change
    create_table :message_receivers do |t|
		t.references :message
		t.string :receiver_id
		t.integer :read_status
    end
  end
end
