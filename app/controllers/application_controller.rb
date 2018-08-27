class ApplicationController < ActionController::Base
  def current_player
    return Player.find_by(id: cookies[:current_player]) if cookies[:current_player]
    nil
  end
end
