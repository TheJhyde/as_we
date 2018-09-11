class ConversationsController < ApplicationController
  before_action :check_player, only: [:create]
  # before_action :check_participants

  def show
    @conversation = Conversation.find(params[:id])
    @from = Player.find(params[:from] || cookies[:current_player])
    @conversation.notifications.find_by(player: @from).update(seen: true)
  end

  def create
    player_one = Player.find(params[:players][0])
    if player_one
      if player_one.conversations.joins(:players).exists?(players: {id: params[:players][1]})
        redirect_to player_one.conversations.joins(:players).find_by(players: {id: params[:players][1]})
      else
        convo = Conversation.new(players: [player_one, Player.find(params[:players][1])])
        if convo.save
          redirect_to convo
        else
          # should display the errors for the users
          p convo.errors.full_messages
        end
      end
    else
      # display the errors somehow
    end
  end

  # private

  #   def check_participants
      
  #   end
end
