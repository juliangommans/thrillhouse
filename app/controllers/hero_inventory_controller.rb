class HeroInventoryController < ApplicationController
  respond_to :json
  before_filter :fetch_inventory, except: [:index, :create]

  def create
    @inventory = HeroInventory.new
    if @inventory.update_attributes inventory_params
      render "hero_inventory/show"
    else
      respond_with @inventory
    end
  end

  def index
    @inventories = HeroInventory.all
  end

  def update
    if @inventory.update_attributes inventory_params
      render "hero_inventory/show"
    else
      respond_with @inventory
    end
  end

  def show; end

  private

  def inventory_params
    params.require(:hero_inventory).permit(:id, :heroes_id, :hero_items_id)
  end

  def fetch_inventory
    @inventory = HeroInventory.find(params[:id])
  end
end
