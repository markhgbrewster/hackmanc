class AddSourceToTextQueue < ActiveRecord::Migration
  def change
    add_column :text_queues, :source, :string
  end
end
