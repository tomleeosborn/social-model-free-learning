/*
 * NAME
 */
(function($){
  jsPsych.plugins["social-learning"] = (function() {
  
      var plugin = {};
  
      var score = 0; 
  
      var displayColor = '#0738db';
          var borderColor = '#197bff';
      var textColor = '#b8fff6';
      
    
      plugin.info = {
        name: "social-learning",
        parameters: {
            choices: {
              type: jsPsych.plugins.parameterType.KEYCODE, // BOOL, STRING, INT, FLOAT, FUNCTION, KEYCODE, SELECT, HTML_STRING, IMAGE, AUDIO, VIDEO, OBJECT, COMPLEX
              pretty_name: 'choices',
              array: true,
              default: undefined,
              description: 'The keys the subject is allowed to press to respond to the stimulus.'
            },
            study_version: {
              type: jsPsych.plugins.parameterType.STRING,
              default: 'social_learning_extended'
            },
            common_prob:{
              type: jsPsych.plugins.parameterType.FLOAT,
              default: 1,
              description: 'common =1, rare = 0'
            },
            debug:{
              type: jsPsych.plugins.parameterType.BOOL,
              default: false,
              description: 'DEBUG TRUE FALSE'
            },
            rews:{
              type: jsPsych.plugins.parameterType.INT,
              description: 'Rewards - will be preloaded', // remove this later 
              default: 1,
              array: true
            },
            init_points:{
              type:jsPsych.plugins.parameterType.INT,
              default: 20,
              description: 'rewards'
            },
            subject_id: {
              type: jsPsych.plugins.parameterType.STRING,
              description: 'Subject ID <- also MTurk ID'
            },
            practice: {
              type: jsPsych.plugins.parameterType.INT,
              default: 0,
              description: '0 for practice session, 1 for non-practice session'
            },
            feedback_time: {
              type: jsPsych.plugins.parameterType.FLOAT,
              default: 500, 
            },
            timeout_time: {
              type: jsPsych.plugins.parameterType.INT,
              default: 2000
            },
            timing_response: {
              type: jsPsych.plugins.parameterType.INT,
              default: 5000
            },
            score_time: {
              type: jsPsych.plugins.parameterType.INT,
              default: 1500
            },
            totalscore_time: {
              type: jsPsych.plugins.parameterType.INT,
              default: 2000
            },
            ntrials: {
              type: jsPsych.plugins.parameterType.INT,
              default: 250,
              description: 'number of non practice trials'
            },
            timing_post_trial: {
              type: jsPsych.plugins.parameterType.INT,
              default: 0
            },
            multiplayer_single_condition: {
              type: jsPsych.plugins.parameterType.INT,
              default: 0,
              description: '0 if multiplayer is in single condition, 1 for otherwise'
            },
            social_agent_id: {
                type: jsPsych.plugins.parameterType.STRING,
                default: null,
                description: 'id for agent used'
            },
            social_agent_data: {
              type: jsPsych.plugins.parameterType.OBJECT, 
              default: null,
              description: 'Data of opponent'
            }, 
            condition: {
              type: jsPsych.plugins.parameterType.STRING, 
              default: null, 
              array: true, 
              description: 'computer, single-player, human'
            },
            rews1a: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            rews1b: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            rews2a: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            rews2b: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            Re: {
              type: jsPsych.plugins.parameterType.INT,
              default: null,
              description: 'reward player chooses'
            },
            trial_n: {
              type: jsPsych.plugins.parameterType.INT,
              default: null,
              description: ''
            },
            start_n: {
              type: jsPsych.plugins.parameterType.INT,
              default: null,
              description: 'res'
            },
            playing_order: {
              type: jsPsych.plugins.parameterType.INT,
              default: null,
              description: 'reward player chooses'
            },
            learning_time: {
              type: jsPsych.plugins.parameterType.FLOAT,
              default: 500, //amount for computer player
            },
             ///load data from agent

             //c1, s2, c2, re, trial_n, left_state, right_state, 
             agent_c1: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            agent_s2: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            agent_c2: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            agent_re: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },

            agent_trial_n: {
              type: jsPsych.plugins.parameterType.INT,
              default: null
            },
            state: {
              type: jsPsych.plugins.parameterType.STRING,
              default: null,
              description: 'state in the experimenet i.e. where we are '
            },
        }
      };
  
    
      plugin.trial = function(display_element, trial) {
  
        progress = jsPsych.currentTrial();
              if (progress.trial_n == 0) {
          score = trial.init_points;
  
        }
  
        var state = 1;
        var part = -1;
  
        var choice1 = -1;
        var choice2 = -1;
  
        var points = -1;
        var common =  -1;
        var state2 = -1;
  
        var points = 0;
  
        var wait_time_1 = null;
        var wait_time_2 = null; 
        
        reverse_mapping_1 = 0; 
        reverse_mapping_2 = 0;
      
  
        if (reverse_mapping_1 == 0) {
            level_1_mapping = [1, 2];
        } else {
            level_1_mapping = [2, 1];
        }
        if (reverse_mapping_2 == 0) {
            level_2_mapping = [1, 2];
        } else {
            level_2_mapping = [2, 1];
        }
  
      // var level_1_mapping = shuffle([1,2]);
      // var level_2_mapping = shuffle([1,2]);
  
      var level_1_left = level_1_mapping[0];
      var level_1_right = level_1_mapping[1];
      var level_2_left = level_2_mapping[0];
      var level_2_right = level_2_mapping[1];
  
      var state_names = ["p_earth","green","yellow"];
      var state_colors = [
        [5, 157, 190],
        [35, 63, 39],
        [240, 187, 57]
      ];


  
      //store responses 
      var setTimeoutHandlers = [];
      var keyboardListener = new Object;
      var response = new Array(2);

      var agent_rt1 = null;
      var agent_rt2 = null;
      var agent_choice1 = null;
      var agent_choice2 = null;

      var agent_key_1 = 0;
      var agent_key_2 = 0;

  
      var cue_time = 500; 
  
      for (var i=0; i<2; i++) {
        response[i]={rt: -1, key: -1};
      }
  
      var timeouts = 0; 
      
      var controlCenter = function(){

        if (trial.practice == 0) { //LOAD DATA FOR SOCIAL TRIALS

          trial.common_prob = trial.social_agent_data[trial.trial_n].common;
          trial.rews1a = trial.social_agent_data[trial.trial_n].rews1a1;
          trial.rews1b = trial.social_agent_data[trial.trial_n].rews1a2;
          trial.rews2a = trial.social_agent_data[trial.trial_n].rews2a1;
          trial.rews2b = trial.social_agent_data[trial.trial_n].rews2a2; 
          // data for social trials
          trial.agent_c1 = trial.social_agent_data[trial.trial_n].Action1; 
          trial.agent_s2 = trial.social_agent_data[trial.trial_n].S2; 
          trial.agent_c2 = trial.social_agent_data[trial.trial_n].Action2; 
          trial.agent_re = trial.social_agent_data[trial.trial_n].Re; 
          trial.agent_trial_n = trial.social_agent_data[trial.trial_n].trial_n;

        } else { //LOAD DATA FOR PRACTICE SINGLE TRIALS

          //load data for the current n 
          trial.common_prob = trial.social_agent_data[trial.trial_n].common;
          trial.rews1a = trial.social_agent_data[trial.trial_n].rews1a;
          trial.rews1b = trial.social_agent_data[trial.trial_n].rews1b;
          trial.rews2a = trial.social_agent_data[trial.trial_n].rews2a;
          trial.rews2b = trial.social_agent_data[trial.trial_n].rews2b; 
          // data for social trials
          trial.agent_c1 = trial.social_agent_data[trial.trial_n].c1; 
          trial.agent_s2 = trial.social_agent_data[trial.trial_n].s2; 
          trial.agent_c2 = trial.social_agent_data[trial.trial_n].c2; 
          trial.agent_re = trial.social_agent_data[trial.trial_n].re; 
          trial.agent_trial_n = trial.social_agent_data[trial.trial_n].trial_n;


        }
  
      
  
      };
  
      var handleComputerResponse = function(){   
        var state = 1; 
        state_name = state_names[0];
        state_color = state_colors[0]; 

        //set reaction times
        agent_rt1 = (Math.random()*1000) + 1000; //between 1 to 2 seconds. 
        agent_rt2 = (Math.random()*1000) + 1000; 

        //load level 1 state 
        if (part == 0) {
          left = level_1_left; 
          right = level_1_right; 
        } else {
          left = level_2_left; 
          right = level_2_right; 
        }
         // kill any remaining setTimeout handlers
         jsPsych.pluginAPI.clearAllTimeouts();   
         // kill keyboard listeners
         jsPsych.pluginAPI.cancelAllKeyboardResponses(); 
  
        display_stage_1(); 

        setTimeout(
          display_stage_2_computer, 
          trial.learning_time
        );

        state = trial.agent_s2;
        state_name = state_names[state-1];
        state_color = state_colors[state-1]; 
        choice1 = trial.agent_c1;
        points = trial.agent_re;
        score = score + points;
        agent_choice2 = trial.agent_c2; 
        
        if (choice1==1){
          agent_key_1 = 70;
        } else {
          agent_key_1 = 74; 
        }

        if (agent_choice2==1) {
          agent_key_2 = 70;
        } else {
          agent_key_2 = 74;
        }

        wait_time_1 = cue_time + trial.learning_time + agent_rt1; 
        
        setTimeout(
          display_stage_3_computer,  
          wait_time_1
        ); 
  
        wait_time_2 = (wait_time_1) + agent_rt2; 

        setTimeout(
          display_stage_after_3_computer,
          wait_time_2
        ); 
        var computerScore = setTimeout(function(){
          display_stage_4_computer(),
          endTrial();
        }, (wait_time_2 + trial.score_time));
        setTimeoutHandlers.push(computerScore); 
  
      };
  
      var  afterResponse = function(info) {
        //kill timers, listeners 
        killListeners();
        killTimers();
      
        //only record the first response      
        if (response[part].key == -1){
          response[part] = info; 
        };
        
         displayStimuli(2); 
    
         if (part == 0) {
          left = level_1_left; //1 
          right = level_1_right; //2
        } else {
          left = level_2_left; //1 
          right = level_2_right; //2 
        }
  
  
        switch(part) {
          case 0: // earth
            common = (trial.common_prob == 1); 
    
            if (String.fromCharCode(response[part].key)==trial.choices[0]) { // left response
              choice1 = left; //1
            } else {
              choice1 = right;					
            }

            if (choice1==1){
              if(common){
                state2 = 2; //go left
              } else {
                state2 = 3; //go right
              }
            } else {
              if (common) { 
                state2 = 3;// go right 
              } else {
                state2 = 2;//go left 
              }
            }
            state = state2;
            break; 

          case 1:
            trial.rews.push(trial.rews1a, trial.rews1b, trial.rews2a, trial.rews2b);

            if (String.fromCharCode(response[part].key)==trial.choices[0]) { // left response
              choice2 = left;//1
            } else {
              choice2 = right;//2 
            }

            // get reward
            if (state == 2){
              points = trial.rews[choice2-1];
            } else {
              points = trial.rews[choice2+1]; 
            }

            score = score + points;
            break;
        };
  
        // //show feedback 
        var feedbackResponse = setTimeout(function(){
  
          if (part==0){// go to level 2 
            display_element.innerHTML= '';
            nextPart();
          } else {
            displayStimuli(3);
            var handleScore = setTimeout(function(){
              displayStimuli(4);
              endTrial();
            }, trial.score_time); 
            setTimeoutHandlers.push(handleScore); 
          }
          }, trial.feedback_time);
          setTimeoutHandlers.push(feedbackResponse); 
  
      };
    
      // display cue 
  
      var displayCue = function(){
        if (trial.condition!='single'){
          if(trial.playing_order==1){
            var my_html = "<br><br><br> Your turn"
            display_element.innerHTML = my_html;
          } else {
            var my_html = "<br><br><br> Your partner's turn"
            display_element.innerHTML = my_html; 
          }
        }
      };
  
   // helps with stimuli_display
      var displayStimuli = function(stage) {
  
        //kill timers, listernes 
        killListeners();
        killTimers();
  
        state_name = state_names[state-1];
        state_color = state_colors[state-1]; 

        if (part == 0) {
          left = level_1_left;
          right = level_1_right;
        } else {
          left = level_2_left;
          right = level_2_right;
        }
      
        if (stage==-1){
          other_html = " <br> <br> <b>Please respond within the <font color = 'red'> 2 second limit! </font></b>";
          display_element.innerHTML = other_html; 
        };
  
  
        if (stage==1){
          display_stage_1();
        };//end of stage 1 
  
        if (stage==2){
          if (String.fromCharCode(response[part].key)==trial.choices[0]){
            $('#jspsych-space-daw-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+right+'_deact.png)');
            $('#jspsych-space-daw-bottom-stim-left').addClass('jspsych-space-daw-bottom-stim-border');
            $('#jspsych-space-daw-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');       
          };
          if (String.fromCharCode(response[part].key)==trial.choices[1]){
            $('#jspsych-space-daw-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+left+'_deact.png)');
            $('#jspsych-space-daw-bottom-stim-right').addClass('jspsych-space-daw-bottom-stim-border');
            $('#jspsych-space-daw-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)'); 
          };
        } //end of stage 2 
  
        if (stage==3){
          if (String.fromCharCode(response[part].key)==trial.choices[0]) { // left response
            if (points>0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/treasure_'+points+'.png)');
            }
            if (points<0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/antimatter_'+(-1*points)+'.png)');
            }
            if (points==0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/noreward.png)');
            }
          }; 
          if (String.fromCharCode(response[part].key)==trial.choices[1]) { 
            if (points>0) {
              $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/treasure_'+points+'.png)');
            }
            if (points<0) {
              $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/antimatter_'+(-1*points)+'.png)');
            }
            if (points==0) {
              $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/noreward.png)');
            }
          }
        }// end of stage 3 
  
        if (stage==4){
          var picture = null;
          var html = '<div id = "myBody" class="jspsych-display-element">';
          display_element.innerHTML = html;
  
          if (points > 0) {
            picture = 'img/treasure_'+points+'.png';
          }
          if (points < 0) {
            picture = 'img/antimatter_'+Math.abs(points)+'.png';
          }
          if (points == 0) {
            picture = 'img/noreward.png';
          }
  
          $("#myBody").css('background-image', 'url("img/earth_planet.png")'); 
  
          $("#myBody").append($('<div>', {
            id: 'jspsych-space-daw-top-rewards',
          }));
  
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-container"><img src="'+picture+'"></div>'))
            
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-text"> = '+points+'</div>'))
            
          $('#jspsych-space-daw-top-rewards').append($('<div style="clear:both; height:20px"></div>'))
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-text">total score: '+score+'</div>'))
  
          $("#myBody").append($('<div>', {
            id: 'jspsych-space-daw-bottom-alien',
          }));
  
          if (String.fromCharCode(response[part].key)==trial.choices[0]) { 
            $('#jspsych-space-daw-bottom-alien').append($('<img src="img/'+state_name+'_stim_'+left+'.png">'));
          } else {
            $('#jspsych-space-daw-bottom-alien').append($('<img src="img/'+state_name+'_stim_'+right+'.png">'));
          }
        }
        };//end of display stimuli 
  
        var startResponseListener = function(){
          if (trial.choices != jsPsych.NO_KEYS){
            var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
              callback_function: afterResponse,
              valid_responses: trial.choices,
              rt_method: 'date',
              persist: false,
              allow_held_key: false
          });
        }
      }
        var killTimers = function() {
          for (var i = 0; i < setTimeoutHandlers.length; i++) {
            clearTimeout(setTimeoutHandlers[i]); 
          }
        };
  
        var killListeners = function() {
          if (typeof keyboardListener !== 'undefined') {
            jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener); 
          }
        };
  
        var nextPart = function() { 
  
          part = part + 1; 


          if (trial.condition=='single'){//single player part 
            trial.playing_order=1; //change to always be human player
            //kill listeners
            killTimers();
            killListeners();

            displayStimuli(1);
            startResponseListener(); 

            //handle timeout
            if (trial.timing_response>0){
              var handleResponse = setTimeout(function(){
                killListeners();
                displayStimuli(-1);
                var handleTimeout = setTimeout(function(){
                    endTrial();
                    part = -1;
                    state = 1; 
                    timeouts++;
                    controlCenter();
                }, trial.timeout_time); 
                setTimeoutHandlers.push(handleTimeout);
              }, trial.timing_response);
              setTimeoutHandlers.push(handleResponse); 
            }
  
          } else {//multiplayer
            if (trial.playing_order==1){//human player
              //kill listeners
              killTimers();
              killListeners();

              displayStimuli(1);
              startResponseListener(); 
                  //handle timeout
              if (trial.timing_response>0){
                var handleResponse = setTimeout(function(){
                  killListeners();
                  displayStimuli(-1);
                  var handleTimeout = setTimeout(function(){
                    endTrial();
                    part = -1;
                    state = 1; 
                    timeouts++;
                    controlCenter();
                  }, trial.timeout_time); 
                  setTimeoutHandlers.push(handleTimeout);
                }, trial.timing_response);
                setTimeoutHandlers.push(handleResponse); 
              }
            } else { //computer player
              killTimers();
              killListeners();
              handleComputerResponse(); 
            }
          }  
        }; 
  
        var endTrial = function() {
          // kill any remaining setTimeout handlers
          jsPsych.pluginAPI.clearAllTimeouts();   
          // kill keyboard listeners
          jsPsych.pluginAPI.cancelAllKeyboardResponses(); 
          // data saving
          if (trial.playing_order==1){//human player
            var trial_data = {
              "subject": trial.subject_id, 
              "social_agent_id":trial.social_agent_id,
              "version": trial.study_version,
              "study_condition": trial.condition,
              "debug": trial.debug, 
              "rt1": response[0].rt,
              "key1": response[0].key,
              "agent_Action1": trial.agent_c1,
              "Action1": choice1,
              "rt2": response[1].rt,
              "key2": response[1].key,
              "agent_Action2": trial.agent_c2,
              "Action2": choice2,
              "agent_Re": trial.agent_re,
              "Re": points,
              "common": trial.common_prob,
              "agent_S2": trial.agent_s2,
              "S2": state2,
              "score": score,
              "practice":trial.practice,
              "rews1a": trial.rews1a,
              "rews1b":  trial.rews1b,
              "rews2a":  trial.rews2a,
              "rews2b":  trial.rews2b, 
              "timeouts": timeouts,
              "trial_n": trial.trial_n + 1,
              "agent_trial_n": trial.agent_trial_n,
              "current_player": trial.playing_order,
            };
  
          } else {
            var trial_data = {
              "subject": trial.subject_id, 
              "social_agent_id":trial.social_agent_id,
              "version": trial.study_version,
              "study_condition": trial.condition,
              "debug": trial.debug, 
              "rt1": wait_time_1,
              "key1": agent_key_1, 
              "agent_Action1": trial.agent_c1,
              "Action1": agent_choice1,
              "rt2": wait_time_2,
              "key2": agent_key_2,
              "agent_Action2": trial.agent_c2,
              "Action2": agent_choice2,
              "agent_Re": trial.agent_re,
              "Re": points,
              "common": trial.common_prob,
              "agent_S2": trial.agent_s2,
              "S2": state2,
              "score": score,
              "practice":trial.practice,
              "rews1a": trial.rews1a,
              "rews1b":  trial.rews1b,
              "rews2a":  trial.rews2a,
              "rews2b":  trial.rews2b, 
              "timeouts": timeouts,
              "trial_n": trial.trial_n,
              "agent_trial_n": trial.agent_trial_n,
              "current_player": trial.playing_order,
            };
          } 
          var handleTotalScore = setTimeout(function(){
            //clear display
            display_element.innerHTML = '';
            $('.jspsych-display-element').css('background-image', '');
            //move to the next trial 
            jsPsych.finishTrial(trial_data); 
            }, trial.totalscore_time);
            setTimeoutHandlers.push(handleTotalScore); 
          }; 
  
  
  /***************************-------------------------******************* */
      
      // functions to display stimuli in various stages 
      var display_stage_1 = function(){ 
        var html = '<div id = "myBody" class="jspsych-display-element">';
        display_element.innerHTML = html;
          // show planet
          $('#myBody').css('background-image', 'url("img/'+state_name+'_planet.png")');
          //create space 
          $('#myBody').append('<div id= "jspsych-space-daw-top-stim-left">'); 
          if (state>1){
            extra_text = 'p_';
            $('#myBody').append($('<div>', {
              style: 'background-image: url(img/'+extra_text+'earth_stim_'+choice1+'_deact.png)',
              id: 'jspsych-space-daw-top-stim-middle',
            }));
          };
          $('#myBody').append('<div id= "jspsych-space-daw-top-stim-right">'); 
          $('#myBody').append('<div style= "clear:both">'); 
          // //add stimuli 
          $('#myBody').append($('<div>', {
            style: 'background-image: url(img/'+state_name+'_stim_'+left+'.png)',
            id: 'jspsych-space-daw-bottom-stim-left',
          }));
          $('#myBody').append($('<div>', {
            id: 'jspsych-space-daw-bottom-stim-middle',
          }));
          $('#myBody').append($('<div>', {
            style: 'background-image: url(img/'+state_name+'_stim_'+right+'.png)',
            id: 'jspsych-space-daw-bottom-stim-right',
          }));
      }// end 

      
      var display_stage_2_computer = function(){
          if(trial.agent_c1==1){
            $('#jspsych-space-daw-bottom-stim-right').css('background-image', 'url(img/p_earth_stim_'+2+'_deact.png)');
            $('#jspsych-space-daw-bottom-stim-left').addClass('jspsych-space-daw-bottom-stim-border');
            $('#jspsych-space-daw-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');  
          }
          if (trial.agent_c1==2){
            $('#jspsych-space-daw-bottom-stim-left').css('background-image', 'url(img/p_earth_stim_'+1+'_deact.png)');
            $('#jspsych-space-daw-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
            $('#jspsych-space-daw-bottom-stim-right').addClass('jspsych-space-daw-bottom-stim-border');
          };   
      };//end 
  
      var display_stage_3_computer = function(){ //maybe put in player information
      
        var html = '<div id = "myBody" class="jspsych-display-element">';
        display_element.innerHTML = html;
        // show planet
        $('#myBody').css('background-image', 'url("img/'+state_name+'_planet.png")');
        //create space 
        $('#myBody').append('<div id= "jspsych-space-daw-top-stim-left">'); 
        var extra_text = 'p_'
        $('#myBody').append($('<div>', {
          style: 'background-image: url(img/'+extra_text+'earth_stim_'+trial.agent_c1+'_deact.png)',
          id: 'jspsych-space-daw-top-stim-middle',
        }));
        $('#myBody').append('<div id= "jspsych-space-daw-top-stim-right">'); 
        $('#myBody').append('<div style= "clear:both">'); 
        // //add stimuli 
        $('#myBody').append($('<div>', {
          style: 'background-image: url(img/'+state_name+'_stim_'+left+'.png)',
          id: 'jspsych-space-daw-bottom-stim-left',
        }));
        $('#myBody').append($('<div>', {
          id: 'jspsych-space-daw-bottom-stim-middle',
        }));
        $('#myBody').append($('<div>', {
          style: 'background-image: url(img/'+state_name+'_stim_'+right+'.png)',
          id: 'jspsych-space-daw-bottom-stim-right',
        }));

  
      };
  
      var display_stage_after_3_computer = function(){    
        switch (agent_choice2) {
          case 1: 
          $('#jspsych-space-daw-bottom-stim-right').css('background-image', 'url(img/'+state_name+'_stim_'+right+'_deact.png)');
            $('#jspsych-space-daw-bottom-stim-left').addClass('jspsych-space-daw-bottom-stim-border');
            $('#jspsych-space-daw-bottom-stim-left').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');       
      
            if (points>0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/treasure_'+points+'.png)');
            }
            if (points<0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/antimatter_'+(-1*points)+'.png)');
            }
            if (points==0) {
              $('#jspsych-space-daw-top-stim-left').css('background-image', 'url(img/noreward.png)');
            }
      
          break;
          case 2: 
          $('#jspsych-space-daw-bottom-stim-left').css('background-image', 'url(img/'+state_name+'_stim_'+left+'_deact.png)');
          $('#jspsych-space-daw-bottom-stim-right').css('border-color', 'rgba('+state_color[0]+','+state_color[1]+','+state_color[2]+', 1)');
          $('#jspsych-space-daw-bottom-stim-right').addClass('jspsych-space-daw-bottom-stim-border');
      
          if (points>0) {
            $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/treasure_'+points+'.png)');
          }
          if (points<0) {
            $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/antimatter_'+(-1*points)+'.png)');
          }
          if (points==0) {
            $('#jspsych-space-daw-top-stim-right').css('background-image', 'url(img/noreward.png)');
          }
          break;
        }
      };
  
  
      var display_stage_4_computer = function(){
        var picture = null;
        var html = '<div id = "myBody" class="jspsych-display-element">';
        display_element.innerHTML = html;
          if (points > 0) {
            picture = 'img/treasure_'+points+'.png';
          }
          if (points < 0) {
            picture = 'img/antimatter_'+Math.abs(points)+'.png';
          }
          if (points == 0) {
            picture = 'img/noreward.png';
          }
  
          $("#myBody").css('background-image', 'url("img/earth_planet.png")'); 
  
          $("#myBody").append($('<div>', {
            id: 'jspsych-space-daw-top-rewards',
          }));
  
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-container"><img src="'+picture+'"></div>'))
            
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-text"> = '+points+'</div>'))
            
          $('#jspsych-space-daw-top-rewards').append($('<div style="clear:both; height:20px"></div>'))
          $('#jspsych-space-daw-top-rewards').append($('<div id="jspsych-space-daw-top-rewards-text">total score: '+score+'</div>'))
  
          $("#myBody").append($('<div>', {
            id: 'jspsych-space-daw-bottom-alien',
          }));
  
          if (agent_choice2==1) { 
            $('#jspsych-space-daw-bottom-alien').append($('<img src="img/'+state_name+'_stim_'+left+'.png">'));
          } else {
            $('#jspsych-space-daw-bottom-alien').append($('<img src="img/'+state_name+'_stim_'+right+'.png">'));
          }
      };
  
      /***************************-------------------------******************* */
        controlCenter();
        if (trial.condition !='single'){
         displayCue(); 
          setTimeout(nextPart, cue_time);
          clearTimeout(); 
        } else {
          nextPart();
        };
       
  
      };
    
      return plugin;
    })();
  })(jQuery);
  