class CharacterController < ApplicationController
  respond_to :json
  before_filter :fetch_character, except: [:index]

  def index
    @characters = Character.all
  end

  def show; end

  def fetch_character
    @character = Character.find(params[:id])
  end

end
