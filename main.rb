require 'rubygems'
require 'sinatra'
require 'sinatra/contrib/all'
require 'pry'

set :sessions, true

helpers do 

  def calculate_total(cards)
    arr = cards.map {|idx| idx[1]}

    total = 0
    arr.each do |card|
      if card== 'ace'
        total += 11
      else
        total+= card.to_i == 0 ? 10 : card.to_i 
      end
    end
     
    # Ace correction
  
    arr.select {|card| card == 'ace'}.count.times do
      break if total <=21 
      total -= 10
    end 
    total
  end

  def win?(cards)
    if calculate_total(cards) == 21
      @show_hit_stay = false
    end
  end

  def view_cards(hand)
    "<img src='/images/cards/#{hand[0]}_#{hand[1]}.jpg' class='card_img'>"
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
  if session[:name] == ''
    @error = 'You have not entered your name yet.'
    erb :new_player
  else
    redirect '/game'
  end

end
  
before do
  @show_hit_stay =true
  @player_stay = false
end

get '/game' do 
  suit = ['diamonds','hearts','clubs', 'spades']
  face = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king']
  session[:deck] = suit.product(face).shuffle!
  session[:player_hand] = []
  session[:dealer_hand]= []
  session[:player_hand] <<session[:deck].pop
  session[:dealer_hand] <<session[:deck].pop
  session[:player_hand] <<session[:deck].pop
  session[:dealer_hand] <<session[:deck].pop
  session[:hit] = params[:hit]
  if calculate_total(session[:player_hand]) == 21
    @success = "Blackjack! #{session[:name]} Wins!! "
    @show_hit_stay = false
  end
  @player_stay = false
  erb :game
  
end

post '/game/player/hit' do 
  @show_hit_stay =true
  session[:player_hand] <<session[:deck].pop
    if win?(session[:player_hand])
      @show_hit_stay = false
    end

    @show_hit_stay =true
    @player_stay=false
    session[:player_hand] <<session[:deck].pop 

    if calculate_total(session[:player_hand]) > 21
      @error = session[:name] + " Busted!"
      @show_hit_stay = false
    end  
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay =true

    @show_hit_stay =false


  if calculate_total(session[:player_hand]) > 21
    @error = session[:name] + ' Busted!'
  end
  @success = 'Player Chose to Stay'
  @player_stay = true
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_stay =false
  @player_stay = true
  while true 
    if calculate_total(session[:dealer_hand]) <  17
      session[:dealer_hand] << session[:deck].pop
    elsif calculate_total(session[:dealer_hand]) > 21
      @success = "Dealer busted! #{session[:name]} wins!"
      break
    else
      redirect '/game/compare'
    end
  end
  erb :game
end

get '/game/compare' do
  @show_hit_stay =false
  @player_stay = true
  if calculate_total(session[:dealer_hand]) > calculate_total(session[:player_hand])
    @error = "Dealer Wins. Try again."
  else
    @success = "#{session[:name]} Wins! Congrats!"
  end
  erb :game
end


