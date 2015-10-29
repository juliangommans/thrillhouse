class LilRpgMapEditorController < ApplicationController
  respond_to :json
  before_filter :fetch_map, except: [:index, :create]

  def index
    @maps = LilRpgMapEditor.all
  end

  def create
    @map = LilRpgMapEditor.new
    if @map.update_attributes map_params
      render "lil_rpg_map_editor/show"
    else
      respond_with @map
    end
  end

  def update
    if @map.update_attributes map_params
      render "lil_rpg_map_editor/show"
    else
      respond_with @map
    end
  end

  def show; end

  private

  def map_params
    params.require(:lil_rpg_map_editor).permit(:id, :name, :size, :map)
  end

  def fetch_map
    @map = LilRpgMapEditor.find(params[:id])
  end
end
