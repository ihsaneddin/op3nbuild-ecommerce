//= require jquery.min.js
//= require jquery-ui
//= require jquery_ujs
//= require_tree  ./jquery
//= require_tree  ./layout
//= require jquery_nested_form
//= require foundation
//= require foundation/foundation.dropdown
//= require foundation/foundation.topbar

$(document).ready(function(e){
	$('.unread-notification').mouseover(function(e){
		if ($(this).hasClass("unread-notification-active"))
		{
			$(this).removeClass('unread-notification-active');
			if (parseInt($('#notifications-count').text()) > 0)
			{
				$('#notifications-count').html(parseInt($('#notifications-count').text()) - 1);
				$.ajax({
				    url: $(this).data('read'),
				    type: 'PUT'
				});
			}
		}
	});
});

$(function(){ $(document).foundation(); });

