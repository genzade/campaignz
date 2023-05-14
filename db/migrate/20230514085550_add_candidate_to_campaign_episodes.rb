class AddCandidateToCampaignEpisodes < ActiveRecord::Migration[7.0]

  def change
    add_reference :campaign_episodes, :candidate, null: false, foreign_key: true
  end

end
