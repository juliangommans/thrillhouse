class MoveController < ApplicationController
  respond_to :json

  def index
    # @fire = Move.where(element: "fire")
    # @water = Move.where(element: "water")
    # @air = Move.where(element: "air")
    # @moves = [@fire, @air, @water].flatten!
    # render json: @moves
    @moves = Move.all
  end

  def show
    @move = Move.find(params[:id])
  end
end
