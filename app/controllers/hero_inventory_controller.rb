class HeroInventoryController < ApplicationController
  respond_to :json
  before_filter :fetch_inventory, except: [:index, :create, :destroy]

  def create
    @inventory = HeroInventory.new
    if params[:hero_inventory][:item_category]
      item = find_hero_item(params[:hero_inventory][:item_colour], params[:hero_inventory][:item_category])
      @inventory[:hero_items_id] = item[:id]
      @inventory[:heroes_id] = params[:hero_inventory][:heroes_id]
      @inventory.save
      render "hero_inventory/show"
    else
      if @inventory.update_attributes inventory_params
        render "hero_inventory/show"
      else
        respond_with @inventory
      end
    end
  end

  def find_hero_item(colour, category)
    HeroItems.find_by(colour: colour, category: category)
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
      @inventory = HeroInventory.find(params[:id])
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
