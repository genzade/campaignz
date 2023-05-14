# frozen_string_literal: true

FactoryBot.define do
  factory :campaign_episode do
    association :campaign
    association :candidate
  end
end
