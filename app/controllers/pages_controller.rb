class PagesController < ApplicationController
  def root
    if current_player && current_player.game
      if current_player.host
        redirect_to game_path(current_player.game)
      else
        redirect_to player_path(current_player)
      end
    else
      @game = Game.new
      @player = Player.new
    end
  end
end
