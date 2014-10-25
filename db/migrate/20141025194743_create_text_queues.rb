class CreateTextQueues < ActiveRecord::Migration
  def change
    create_table :text_queues do |t|
      t.string :dest
      t.timestamp :send_after
      t.string :message

      t.timestamps
    end
  end
end
