/*
 * Example plugin template
 */

jsPsych.plugins["load-opponent"] = (function() {

  var plugin = {};

  plugin.info = {
    name: "load-opponent",
    parameters: {
    }
  }

  plugin.trial = function(display_element, trial) {
    
    var style = "<style> #myProgress { width: 100%; background-color: grey; }\
    #myBar { width: 1%; height: 30px; background-color: green; </style>"; 
    
    var html = style + '<br><br><div id ="myProgress"><div id ="myBar">10%</div></div>';
    display_element.innerHTML = html;


    // function move() {
    //     var elem = document.getElementById("myBar"); 
    //     var width = 1;
    //     var id = setInterval(frame, 10);
    //     function frame() {
    //       if (width >= 100) {
    //         clearInterval(id);
    //       } else {
    //         width++; 
    //         elem.style.width = width + '%'; 
    //       }
    //     }
    //   };

    //   move(); 


  };

  return plugin;
})();
