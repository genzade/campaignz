class CreateCampaigns < ActiveRecord::Migration[7.0]

  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.integer :total_votes, default: 0

      t.timestamps
    end
  end

end
