$(document).ready(function(){
	$('form#product-new-brand').submit(function(e){
		e.preventDefault();
		var form = $(this),
			 	method = form.attr('method'),
			 	url = form.attr('action'),
			 	process = false,
			 	content = false,
			 	data = new FormData(form[0]);
	})
});