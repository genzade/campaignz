class AddCampaignToCampaignEpisodes < ActiveRecord::Migration[7.0]

  def change
    add_reference :campaign_episodes, :campaign, null: false, foreign_key: true
  end

end
