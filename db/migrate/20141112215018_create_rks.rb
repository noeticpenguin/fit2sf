class CreateRks < ActiveRecord::Migration
  def change
    create_table :rks do |t|
      t.string :authtoken

      t.timestamps
    end
  end
end
