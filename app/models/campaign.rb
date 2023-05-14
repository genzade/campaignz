# frozen_string_literal: true

class Campaign < ApplicationRecord

  has_many :campaign_episodes, dependent: :destroy
  has_many :candidates, through: :campaign_episodes

  validates :name, presence: true

end
