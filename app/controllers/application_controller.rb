class ApplicationController < ActionController::Base
  def current_player
    return Player.find_by(id: cookies[:current_player]) if cookies[:current_player]
    nil
  end

  def current_game
    return Game.find_by(id: cookies[:current_game]) if cookies[:current_game]
    nil
  end

  def redirect_to_main
    if current_player && current_player.game && !current_player.left
      if current_player.host
        redirect_to game_path(current_player.game)
      else
        redirect_to player_path(current_player)
      end
    end
  end

  def check_player
    redirect_to root_path and return unless current_player
  end

  def match_player
    redirect_to root_path and return unless cookies[:current_player] == params[:id]
  end

  def check_host
    redirect_to current_player and return unless current_player.host?
  end
end
