require 'rubygems'
require 'sinatra'

set :sessions, true
set :protection, :except => [:json_csrf]

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
     
    # ACE CORRECTION
  
    arr.select {|card| card == 'ace'}.count.times do
      break if total <=21 
      total -= 10
    end 
    total
  end

  def view_cards(hand)
    "<img src='/images/cards/#{hand[0]}_#{hand[1]}.jpg' class='card_img'>"
  end

  def win_money
    session[:money]+= (session[:bet] *2)
  end
end
      

get '/' do 
  redirect '/new_player'
end

get '/new_player' do 
  erb :new_player
end
#ASK FOR PLAYER NAME AND DEFAULTS MONEY TO $500
post '/new_player' do 
  session[:money] = 500
  session[:name]= params[:name]
  if session[:name] == ''
    @error = 'You have not entered your name yet.'
    erb :new_player
  else
    redirect '/bet'
  end
end

get '/bet' do 
  erb :bet
end
#ASKS FOR BET AMOUNT AND SUBTRACTS FROM MONEY PILE
post '/bet' do 
  session[:bet] = params[:bet].to_i
  session[:money] -= session[:bet]
  if session[:bet] < 5
    @error = 'Minimum buy in is $5'
    erb :bet
  else
    redirect  '/game'
  end
end
# IV USED TO SHOW HIT/STAY BUTTONS AND TO CHECK IF PLAYER STAYED  
before do
  @show_hit_stay =true
  @player_stay = false
end
#DEALS CARDS. PLAYER AUTOMATICALLY WINS IF BLACKJACK
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
    win_money
    @success = "Blackjack! #{session[:name]} Wins!! "
    @show_hit_stay = false
    @play_again= true
  end
  @player_stay = false
  erb :game
  
end

post '/game/player/hit' do 
  @show_hit_stay =true
  session[:player_hand] <<session[:deck].pop
  if calculate_total(session[:player_hand]) > 21
      @error = session[:name] + " Busted!"
      @show_hit_stay = false
      @play_again= true
    end  
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay =false
  if calculate_total(session[:player_hand]) > 21
    @error = session[:name] + ' Busted!'
    @play_again= true
  else
    @success = 'Player Chose to Stay'
    @player_stay = true
    redirect '/game/dealer'
  end
  erb :game
end

get '/game/dealer' do
  @show_hit_stay =false
  @player_stay = true
  while true 
    if calculate_total(session[:dealer_hand]) <  17
      session[:dealer_hand] << session[:deck].pop
    elsif calculate_total(session[:dealer_hand]) > 21
      win_money
      @success = "Dealer busted! #{session[:name]} wins!"
      @play_again= true
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
    @play_again= true
  else
    win_money
    @success = "#{session[:name]} Wins! Congrats!"
    @play_again= true
  end
  erb :game
end

get '/again' do 
  session[:bet] = params[:bet].to_i
  session[:money] -= session[:bet]
  if session[:bet] < 5
    @error = 'Minimum buy in is $5'
    erb :bet
  else
    redirect  '/game'
  end
end


