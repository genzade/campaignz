# frozen_string_literal: true

class CampaignsController < ApplicationController

  def index
    @campaigns = Campaign.all

    render locals: {
      campaigns: @campaigns
    }
  end

end
