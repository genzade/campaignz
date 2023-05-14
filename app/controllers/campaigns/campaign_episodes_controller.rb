# frozen_string_literal: true

module Campaigns
  class CampaignEpisodesController < ApplicationController

    def index
      @campaign_episodes = campaign
        .campaign_episodes
        .includes(:candidate)
        .where(campaign: params[:campaign_id])
        .order(score: :desc)

      render locals: {
        campaign_name: campaign.name,
        campaign_episodes: @campaign_episodes
      }
    end

    private

    def campaign
      @campaign ||= Campaign.includes(:campaign_episodes).find(params[:campaign_id])
    end

  end
end
