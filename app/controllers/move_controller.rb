class MoveController < ApplicationController
  respond_to :json

  def index
    @fire = Move.where(element: "fire")
    @water = Move.where(element: "water")
    @air = Move.where(element: "air")
    @moves = [@fire, @air, @water].flatten!
    render json: @moves
  end
end
