class ConversationsController < ApplicationController
  before_action :check_player

  def show
    @conversation = Conversation.find(params[:id])

    redirect_to current_player and return unless (@conversation.players.exists?(id: cookies[:current_player]) || current_player.host?)

    @from = Player.find(params[:from] || cookies[:current_player])
    @conversation.notifications.find_by(player: @from).update(seen: true)
  end

  def create
    player_one = Player.find(params[:players][0])
    if player_one
      # If, among player_one's conversations, one exists that has a player with the id of the second player, redirect to the conversation
      # If we ever wanted to have conversations with >2 players, this would need to be revised to check if there's a conversation with exact the list of ids provided here
      # But for now we don't
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
end
