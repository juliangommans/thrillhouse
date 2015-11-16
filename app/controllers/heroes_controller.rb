class HeroesController < ApplicationController
  respond_to :json

  def show
    @hero = Heroes.find(params[:id])
  end

  def index
    @heroes = Heroes.all
  end


end
