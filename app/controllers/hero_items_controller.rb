class HeroItemsController < ApplicationController
  respond_to :json

  def show
    @hero_item = HeroItems.find(params[:id])
  end

  def index
    @hero_items = HeroItems.all
  end
end