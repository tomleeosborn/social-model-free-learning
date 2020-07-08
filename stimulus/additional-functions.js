var num_trials = null; 
var practice_2_trials = null;
var first_player = null;



var images = [
	'img/p_earth_stim_1.png',
	'img/p_earth_stim_2.png',
	'img/p_earth_stim_1_deact.png',
	'img/p_earth_stim_2_deact.png',
	'img/green_planet.png',
	'img/green_stim_1.png',
	'img/green_stim_2.png',
	'img/green_stim_1_deact.png',
	'img/green_stim_2_deact.png',
	'img/yellow_planet.png',
	'img/yellow_stim_1.png',
	'img/yellow_stim_2.png',
	'img/yellow_stim_1_deact.png',
	'img/yellow_stim_2_deact.png',
	'img/antimatter_1.png',
	'img/antimatter_2.png',
	'img/antimatter_3.png',
	'img/antimatter_4.png',
	'img/antimatter_5.png',
	'img/treasure_1.png',
	'img/treasure_2.png',
	'img/treasure_3.png',
	'img/treasure_4.png',
	'img/treasure_5.png',
	'img/noreward.png',
	'img/example_rockets.png',
	'img/example_aliens.png',
	'img/example_planets.png',
	'img/game_structure_noaliens.png',
	'img/game_structure.png'
	];
	
	function save_data(data,table_name){
	
		for (i = 0; i < data.length; i++) {
			delete data[i].trial_index;
			delete data[i].trial_type;
			delete data[i].internal_node_id; 
		}
	
		$.ajax({
			type:'post',
			cache: false,
			url: 'savedata.php', // change this to point to your php file.
			// opt_data is to add additional values to every row, like a subject ID
			// replace 'key' with the column name, and 'value' with the value.
			data: {
				table: table_name,
				json: JSON.stringify(data),
			},
			success: function(){
				console.log("Data successfully saved to database");
			}// write the result to javascript console
			//success: function(output) { console.log(output); } // write the result to javascript console
		});
	}

	var get_score = function(data){
		var my_score = data[data.length-1];
		console.log(my_score)
		return my_score; 
	}
	
	// JS equivalent of PHP's $_GET
	function parseURLParams(url) {
		var queryStart = url.indexOf("?") + 1,
			queryEnd   = url.indexOf("#") + 1 || url.length + 1,
			query = url.slice(queryStart, queryEnd - 1),
			pairs = query.replace(/\+/g, " ").split("&"),
			parms = {}, i, n, v, nv;
	
		if (query === url || query === "") {
			return;
		}
	
		for (i = 0; i < pairs.length; i++) {
			nv = pairs[i].split("=");
			n = decodeURIComponent(nv[0]);
			v = decodeURIComponent(nv[1]);
	
			if (!parms.hasOwnProperty(n)) {
				parms[n] = [];
			}
	
			parms[n].push(nv.length === 2 ? v : null);
		}
		return parms;
	}

var instructions_single_player = function(){
	var instructions = ["<style>div {padding-right: 50px; padding-left: 50px; padding-right: 50px; padding-bottom:10px}</style>\
		Welcome this HIT!<br><br>Please read all the instructions very carefully. It takes some time, but otherwise you will not know what to do and will earn less money.<br><br>\
		This HIT will take about 35 minutes. We don't allow duplicate ID addresses. We apologize for any inconvenience this causes. \
		We don't allow duplicate ID addresses. We apologize for any inconvenience this causes.<br><br>\
		The game has been tested on the latest versions of Firefox and Chrome only. We can't guarantee that it works on other browsers. Should you have trouble, such as the game freezing\
		 or not progressing, it is most likely an issue with your browser.",
		"<br><br>In this HIT, you will be hunting for space treasure on two different planets.\
		<br><br><img style='margin:0px auto;display:block;height:200px' src='img/example_planets.png'/>",
		"<br>There are two spaceships that can get you to the planets. In the game, you can choose the left spaceship by pressing 'F', and the right spaceship by pressing 'J'.\
		<br><br><img style='margin:0px auto;display:block;height:100px' src='img/example_rockets.png'/><br>\
		The spaceship on the left usually goes to the green planet, and the spaceship on the right usually goes to the yellow planet.<br><br>\
		<img style='margin:0px auto;display:block;height:200px' src='img/example_planets.png'/><br>\
		But 20% of the time, the spaceship on the left gets lost and goes to the yellow planet. And 20% of the time, the spaceship on the right gets lost and goes to the green planet. \
		When this happens is completely random.",
		"In other words, the game works like this:<br><br><img  style='margin:0px auto;display:block;height:400px' src='img/game_structure_noaliens.png'/><br>\
		These probabilities don't change throughout the game. Don't worry about memorizing them now; you'll get lots of practice.",
		"<br><br>How do you actually get space treasure once you're on the planet? Well, the treasure is controlled by aliens who live on the planet.<br><br>\
		<img style='margin:0px auto;display:block;height:100px' src='img/example_aliens.png'/><br><br>\
		Each planet has two aliens, which you can select by pressing 'F' (left alien) or 'J' (right alien).",
		"<br><br>The aliens will give you varying amounts of space treasure throughout the game. Sometimes, an alien will give you lots of treasure:\
		<br><br><img style='margin:0px auto;display:block' src='img/treasure_5.png'/><br>\
		Other times, it won't give you any treasure at all.<br><br>\
		<b>Treasure is good. The more treasure you get, the more bonus money you receive at the end of the experiment.</b> So you want to pay attention and pick the alien which is currently giving the most treasure.",
		"<br><br>But sometimes, instead, of giving you treasure, an alien will give you antimatter: <br><br><img style='margin:0px auto;display:block' src='img/antimatter_3.png'/><br><br>\
		<b>Antimatter is bad. Every time you get antimatter, you lose some of your bonus money.</b> So you want to try to avoid aliens that are currently giving you antimatter.<br><br>\
		But remember, what an alien gives you changes throughout the experiment, so you have to stay on your toes. An alien that's giving you antimatter now might give you treasure later, or vice versa.",
		"<br><br>So, to summarize the game: Aliens can give you treasure (which increases your bonus payment) or antimatter (which decreases your bonus payment). \
		There are two aliens on each planet, and what they give you is constantly changing. You'll have to figure out, through trial and error, which alien is the best at any given moment.<br><br>\
		<img style='margin:0px auto;display:block;height:100px' src='img/example_aliens.png'/><br>\
		To get to the alien you want, you'll choose a spaceship. \
		Usually, the spaceship on the left brings you to the green planet and the spaceship on the right brings you to the yellow planet.\
		But sometimes, the spaceships get lost and go to the other planet.<br><br>\
		<img style='margin:0px auto;display:block;height:100px' src='img/example_rockets.png'/>",
		"In other words, the full game looks like this:<br><br><img  style='margin:0px auto;display:block;height:400px' src='img/game_structure.png'/>",
		"<br><br>Let's give you some practice with the game. First you will do " + num_trials +  " practice trials. These won't count towards your bonus payment.<br><br>\
		Our advice is to think carefully about your strategy, but also to trust your instincts. \
		By concentrating throughout the experiment you can increase the number of points you win by a lot. \
		There is an element of chance, but also room for skill.<br><br>Remember, press 'F' to select the spaceship or alien on the left, and press 'J' to select the spaceship or alien on the right.<br><br> \
		<b> <font color = 'red'>During each trial, you will have 2 seconds to select a spaceship and 2 seconds to select an alien</font>."];
	return instructions
};

var instructions_multiplayer = function(){
	var instructions = ["<style>div {padding-right: 50px; padding-left: 50px; padding-right: 50px; padding-bottom:10px}</style>\
		<br><br>We are now going to add another dimension to this game. \
		Instead of hunting for treasure alone, you will now <u><b> partner </u></b>with another player. <br><br>\
		What this means is that you and your partner will take turns to complete the trials. <br><br>\
		Your partner will be another <b> <font color = 'red'>Mturk worker</font></b>. \
		Just like you the Mturk worker that you have been assigned as your partner has not played this game previously. \
		And just like you, the Mturk worker will be trying to maximize their rewards (bonus). \
		You will be able to see all the moves that your partner makes <br><br>\
		At the end of the task, you will <u><b> keep all the bonus amount </b> </u>that you and your partner make together.",
		"<br><br>In other words, the game is still the same as it was at the beginning. The only difference is that you will now take turns with another Mturk worker.<br><br>\
		That is, you will play one trial and then you will watch your partner play the next trial.\
		Just like you, the Mturk worker has not played this game before and will be trying to earn as much bonuses as possible. <br><br>\
		At the end of the experiment, you will keep all the bonus payments that you and your partner earn. \
		As such, it is important to pay attention to the moves that your partner will be making to increase the amount of bonus that you earn <br>",
		"<br><br> Let us give you some practice with taking turns in the game. You will do " + practice_2_trials + " practice trials. \
		These won't count towards your bonus payment. \
		By concentrating throughout the experiment, you can increase the number of points you win by a lot. \
		There is an element of chance, but also room for skill.<br><br>\
		Remember, press 'F' to select the spaceship or alien on the left, and press 'J' to select the spaceship or alien on the right.<br><br>\
		At the beggining of each trial, you will be notified whether it's your turn or your partner's.\
		Once again, you will have 2 seconds to select a spaceship and 2 seconds to select an alien. \
		When you're ready to start, please continue."
	];
	return instructions; 
}



var instruction_final= function() {
	var instructions = [
		"<style>div {padding-right: 50px; padding-left: 50px; padding-right: 50px; padding-bottom:10px}</style>\
		<br><br>Ok, you have finished the practice trials. Now, you and your partner will do real trials which will count towards your bonus payment. \
		You will get a bonus payment of <b> <font color = 'red'> 1 cent for every 2 points </b> </font>you've earned by the end. \
		On average people win about $0.75, and some have won more than $2.00. We'll start you off with 20 points.<br><br>\
		At the end of the game, you will keep all the bonus payments that both you and your partner have earned together. <br><br> \
		Once again, by concentrating throughout the experiment, you can increase the number of points you win by a lot. \
		As mentioned earlier, you will be able to see your partner moves, but they will not be able to see your moves. <br><br> \
		This part of the game takes most people about 15 to 20 minutes.", 
		"<br><br>"+ first_player + " will go first (i.e. play the first trial). <br><br> Click next when ready. Good luck!"
	];
	return instructions; 
}; 

var iri_preamble = "<style>div {padding-right: 3ch; padding-left: 3ch; padding-bottom:3ch}</style>\
<div> <p align='left'> <b> <font color = 'red'> Instructions: </font> </b>\
The following statements inquire about your thoughts and feelings in a variety of situations.  \
For each item, indicate <b> how well it describes you </b> <font color = 'red'>by choosing the appropriate letter </b> </font>on the \
scale beneath the question:  A, B, C, D, or E.  When you have decided on your answer, click on the \
the radio button  below the question.  <b> <font color = 'red'> READ EACH ITEM CAREFULLY BEFORE RESPONDING.</b> </font> \
Answer as honestly as you can.  Thank you.\
"

var iri_scale = [
	"A <br> Does not describe me",
	"B",
	"C",
	"D",
	"E <br> Describes me very well"
]; 
