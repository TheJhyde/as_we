class GamesController < ApplicationController
  before_action :check_player, only: [:show, :update]
  before_action :check_host, only: [:show, :update]

  def create
    game = Game.create
    host = Player.create(game: game, host: true)
    cookies[:current_player] = host.id
    cookies[:current_game] = game.id
    redirect_to game
  end

  def show
    # Should probably do some sort of preloading here, but, eh
    @game = Game.find(params[:id])
    @players = @game.players

    @host = @game.players.find_by(host: true)
    @hrn = Player.find_or_create_by(number: "HRN")
  end

  def update
    game = Game.find(params[:id])
    if game_params[:state] == "running" && game.state != "running"
      game.start
    elsif game_params[:state] == "end" && game.state != "end"
      game.end
    end

    redirect_to game
  end

  private
    def game_params
      params.require(:game).permit(:state)
    end
end
