class PlayersController < ApplicationController
  def create
    @game = Game.find_by(code: params[:player][:code])
    if @game
      @player = Player.create(game: @game)
      session[:current_player] = @player.id
      session[:current_game] = @game.id
      redirect_to @player
    elsif @game.nil?
      flash[:alert] = "Game not found."
      redirect_to root_path
    elsif @game.state != "begin"
      flash[:alert] = "Cannot join game in progress."
      redirect_to root_path
    end
  end

  def show
    @player = Player.find(params[:id])
  end
end
