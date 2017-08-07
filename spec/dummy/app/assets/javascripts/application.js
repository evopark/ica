//= require jquery
//= require jquery.turbolinks
//= require bootstrap-sprockets
//= require jquery-ui

//= require_tree .

$(function() {
    /* Activating Best In Place */
    $(".best_in_place").best_in_place();
});

window.fa_icon = function() {
    var classes = Array.prototype.map.call(arguments, function(arg) { return "fa-" + arg })
    return "<i class=\"fa " + classes.join(' ') + "\"></i>"
}
