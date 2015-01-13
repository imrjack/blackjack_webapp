require 'rubygems'
require 'sinatra'
require 'pry'
require 'sinatra/contrib/all'


set :sessions, true

BLACKJACK = 21

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
     "/images/cards/#{hand[0]}_#{hand[1]}.jpg"
  end

  def win_money
    session[:money]+= (session[:bet] *2)
  end

  def player_lose
    player_total = calculate_total(session[:player_hand])
    dealer_total = calculate_total(session[:dealer_hand])
    if player_total > BLACKJACK
      @error = session[:name] +" Busted!"
    elsif dealer_total == BLACKJACK
      @error = "Dealer has BlackJack! TOO BAD!"
    else 
      @error = "Dealer Wins!"
    end
  end

  def player_win(msg)
    if calculate_total(session[:player_hand]) == BLACKJACK
      @success = "#{session[:name]} has BlackJack! Good job!"
    else  
      @success = "#{session[:name]} Wins! #{msg}" 
    end
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
    redirect '/game'
  end
end
# IV USED TO SHOW HIT/STAY BUTTONS AND TO CHECK IF PLAYER STAYED  
before do
  @show_hit_stay =true
  @player_stay = false
end
#DEALS INITIAL CARDS. 
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
  session[:turn] = 'player'
  #PLAYER AUTOMATICALLY WINS IF BLACKJACK

  player_total = calculate_total(session[:player_hand])
  if  player_total == 21
    player_win("")
    @show_hit_stay = false
    @play_again= true
  end
  erb :game
end

post '/game/player/hit' do 
  @show_hit_stay =true
  session[:player_hand] <<session[:deck].pop
  player_total = calculate_total(session[:player_hand])
  if player_total > 21
    player_lose
    @show_hit_stay = false
    @play_again= true
  end  
  erb :game, layout: false
end

post '/game/player/stay' do
  
  @player_stay =true
  @show_hit_stay = false
  @dealer_hit= true
  erb :game,layout: false
end

post '/game/dealer' do
  session[:turn] = 'dealer'
  @show_hit_stay =false
  @player_stay = true
  @dealer_score = true
  player_total = calculate_total(session[:player_hand])
  dealer_total = calculate_total(session[:dealer_hand]) 

    if dealer_total <  17
      session[:dealer_hand] << session[:deck].pop
      if dealer_total < 17
        @dealer_hit = true
      end
    # elsif dealer_total >= 17 && dealer_total <=21
    #   @dealer_hit = false
    #   @success = 'Dealer chose to stay'
    #   redirect '/game/compare'
    elsif dealer_total > 21
      @dealer_hit= false
      player_win("Dealer Busted!")
      @play_again = true
    else
      @dealer_hit= false
      redirect '/game/compare'
    end
  erb :game,layout: false
end

get '/game/compare' do
  @dealer_score = true
  @dealer_hit = false
  @show_hit_stay =false
  @player_stay = true
  player_total = calculate_total(session[:player_hand])
  dealer_total = calculate_total(session[:dealer_hand]) 

  if player_total < dealer_total
    player_lose
    @play_again = true
  elsif player_total > dealer_total
    player_win(" with a total of #{player_total}.  Good Job!")
    @play_again= true
  else 
    @success = "It's a Tie!"
    @play_again = true
  end
  erb :game,layout: false
end

get '/again' do
@dealer_hit = false 
  session[:bet] = params[:bet].to_i
  session[:money] -= session[:bet]
  if session[:bet] < 5
    @error = 'Minimum buy in is $5'
    erb :bet
  else
    redirect  '/game'
  end
end


