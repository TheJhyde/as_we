class PagesController < ApplicationController
  before_action :redirect_to_main

  def root
    @game = Game.new
    @player = Player.new
  end
end
