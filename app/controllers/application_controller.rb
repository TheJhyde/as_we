class ApplicationController < ActionController::Base
  def current_player
    return Player.find_by(id: session[:current_player]) if session[:current_player]
    nil
  end
end
