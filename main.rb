require 'rubygems'
require 'sinatra'
require 'sinatra/contrib/all'
require 'pry'

set :sessions, true

helpers do 

  def calculate_total(cards)
    arr = cards.map {|idx| idx[0]}

    total = 0
    arr.each do |card|
      if card== 'Ace'
        total += 11
      else
        total+= card.to_i == 0 ? 10 : card.to_i 
      end
    end
     
    # Ace correction

    arr.select {|card| card == 'Ace'}.count.times do
      break if total <=21 
      total -= 10
    end 
    total
  end

  def win?(cards)
    if calculate_total(cards) == 21
      @success = 'Blackjack! you win!'
    end
  end

end
      

get '/' do 
  redirect '/new_player'
end

get '/new_player' do 
  erb :new_player
end

post '/new_player' do 
  session[:name]= params[:name]
  redirect '/game'
end
  
before do
  @show_hit_stay =true
end

get '/game' do 
  suit = ['Diamond','Hearts','Clubs', 'Spades']
  face = ['Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King']
  session[:deck] = face.product(suit).shuffle!
  session[:player_hand] = []
  session[:dealer_hand]= []
  session[:player_hand] <<session[:deck].pop
  session[:dealer_hand] <<session[:deck].pop
  session[:player_hand] <<session[:deck].pop
  session[:dealer_hand] <<session[:deck].pop
  session[:hit] = params[:hit]
  win?(session[:player_hand])
  erb :game

end

post '/game/player/hit' do 
  @show_hit_stay =true
  session[:player_hand] <<session[:deck].pop
    if win?(session[:player_hand])
      @show_hit_stay = false
    end

    if calculate_total(session[:player_hand]) > 21
      @error = session[:name] + " Busted!"
      @show_hit_stay = false
    end  
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay =true

  if calculate_total(session[:player_hand]) > 21
    @error = session[:name] + ' Busted!'
  end
  @success = 'Player Chose to Stay'
  erb :game
  
end
