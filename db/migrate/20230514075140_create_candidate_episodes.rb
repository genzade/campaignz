class CreateCandidateEpisodes < ActiveRecord::Migration[7.0]

  def change
    create_table :campaign_episodes do |t|
      t.integer :score, default: 0
      t.integer :invalid_votes, default: 0

      t.timestamps
    end
  end

end
