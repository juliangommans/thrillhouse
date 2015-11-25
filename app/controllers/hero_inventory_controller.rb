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

  def destroy
    if params[:heroes_id]
      items_to_destroy = HeroInventory.where(heroes_id: params[:heroes_id], hero_items_id: params[:hero_items_id])
      params[:id].to_i.times do |x|
        items_to_destroy[x].destroy
      end
    else
      @inventory.destroy
    end
    render json: { status: 200 }
  end

  private

  def inventory_params
    params.require(:hero_inventory).permit(:id, :heroes_id, :hero_items_id, :spell)
  end

  def fetch_inventory
    @inventory = HeroInventory.find(params[:id])
  end
end
