# frozen_string_literal: true

class CampaignEpisode < ApplicationRecord

  belongs_to :campaign
  belongs_to :candidate

end
