# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :check_player, only: [:show, :update]
  before_action :check_host, only: [:show, :update]

  def create
    game = Game.create
    host = Player.create(game: game, role: :host)
    hrn = Player.create(game: game, role: :hrn, number: "HRN")
    cookies[:current_player] = host.id
    cookies[:current_game] = game.id
    redirect_to game
  end

  def show
    @game = Game.includes(:players).find(params[:id])
    @players = @game.players

    @host = @game.players.includes(:conversations).find_by(role: :host)
    @hrn = @game.players.includes(:conversations).find_by(role: :hrn)
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
