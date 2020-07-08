// selects opponent from dataset 

var selectPartner = function(data) {

    //take keys from the json file and makes an array from them 
    players_lists = Object.keys(data); 
   
    //now selects a random player ID 

    opponent_id = players_lists[Math.floor(Math.random() * players_lists.length)]; 
    return opponent_id;
  };

// displays opponents id 

var partnerData = function(data, opponent_id) {
    return data[opponent_id];

};
//selects who goes first and who does second
var selectPlayingOrder = function(){
    var players = [1,2];
    return players[Math.floor(Math.random() * players.length)];
  }; 