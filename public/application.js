$(document).ready(function() {
player_hit();
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
    $(".cards").effect('bounce');
    return false;
  });
}

function dealer_hit(){
    $(document).on('click','#stay_button input', function(){
      $.ajax({
        type:'GET',
        url:'/game/dealer'

      }).done(function(msg){
        $('#game').replaceWith(msg);
      });
    
      return false;
      
    });
}


