class PlayersController < ApplicationController
  before_action :redirect_to_main, only: [:login_page]
  before_action :check_player, only: [:show, :edit, :update]
  before_action :match_player, only: [:show, :edit, :update]

  def create
    @player = Player.new(code: params[:player][:code].upcase)
    if @player.save
      set_cookies(@player)
      redirect_to @player
    else
      flash[:alert] = @player.errors.full_messages[0]
      redirect_to root_path
    end
  end

  def show
    @player = Player.includes(:game, :conversations).find(params[:id])
    if @player.host || @player.number == "HRN"
      redirect_to current_player.game and return
    end
  end

  def edit
    @player = Player.find(params[:id])
    @outcomes = @player.game.outcomes
  end

  def update
    player = Player.find(params[:id])
    player.update(player_params)
    if player_params[:left] && player_params[:left] == "true"
      player.leave
    end
    redirect_to player
  end

  def login_page
    @players = Player.where(left: false)
  end

  def login
    @player = Player.find(params[:id])
    if @player.save
      set_cookies(@player)
      redirect_to @player
    else
      flash[:alert] = "We could not find that player"
      redirect_to root_path
    end
  end

  private
    def player_params
      params.require(:player).permit(:left, :change, :fate)
    end

    # games last 90 minutes + an extra 90 minutes for before game events. Just to be safe
    def set_cookies(player)
      cookies[:current_player] = {value: player.id, expires: 3.hours}
      cookies[:current_game] = {value: player.game.id, expires: 3.hours}
    end
end
