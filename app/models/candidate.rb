# frozen_string_literal: true

class Candidate < ApplicationRecord

  has_many :campaign_episodes, dependent: :destroy
  has_many :campaigns, through: :campaign_episodes

  validates :name, presence: true

end
