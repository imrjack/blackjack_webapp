$(document).ready(function() {
player_hit();
player_stay();
dealer_hit();
});

function player_hit(){
  $(document).on('click', '#hit_button input', function(){

    $.ajax({
      type:'POST',
      url: '/game/player/hit'
      }).done(function(msg){
      $('#game').replaceWith(msg);

    });
      return false;
  });
}

function player_stay(){
    $(document).on('click','#stay_button input', function(){
      $.ajax({
        type:'POST',
        url:'/game/player/stay'
      }).done(function(msg){
        $('#game').replaceWith(msg);
      });
    
      return false;
      
    });
}

function dealer_hit(){
    $(document).on('click','#dealer_hit', function(){
      $.ajax({
        type:'get',
        url:'/game/dealer'
      }).done(function(msg){
        $('#game').replaceWith(msg);
      });
    
      return false;
      
    });
}


