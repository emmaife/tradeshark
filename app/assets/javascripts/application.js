// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).on("click",".favorite",function(){
   var post_id = $(this).attr('id');
   var x = $(this);
   $.ajax({
    type: "POST",
    url: '/favorites/' + post_id,
    success: function() {
      // change image or something
    
      if (window.location.pathname == '/favorites'){
        $("#row_" + post_id).remove();
      }
      else {
        if (x.html() == 'Add to Watchlist') {
          x.text('Remove From Watchlist');
        }
        else {
          x.text('Add to Watchlist');
        }
      }
    }
  })
});
