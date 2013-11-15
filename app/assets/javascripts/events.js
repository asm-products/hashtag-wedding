var EventHelper = EventHelper || {};

EventHelper.selectedImages = EventHelper.selectedImages || [];

EventHelper.modifySelectedImage = function() {
	item = $(this).data('item');
	
	if(EventHelper.selectedImages.indexOf(item) == -1) {
		EventHelper.selectedImages.push(item);	
	} else {
		EventHelper.selectedImages.pop(item);	
	}		
};

EventHelper.uploadImages = function(eventId) {
	if(EventHelper.selectedImages.length > 0) {
		$.post('/photos', { 'id': eventId, 'provider': 'facebook', 'photos': JSON.stringify(EventHelper.selectedImages) }).done(function(){
			
		}).fail(function(){
			
		});
	} else {
		alert('choose images');
	}
};

EventHelper.addTag = function(eventId) {
	$.post('/events/' + eventId + '/tag', { 'tag': $('#tag-input').val() }).done(function() {
		
	}).fail(function() {
		
	});
};

EventHelper.getTag = function(tagName, provider, isCheck) {
	$.get('/events/' + tagName + '/tag_details/' + provider).done(function(data){
		
		if(isCheck) {
			
		} else {
			if(provider == 'instagram') {
			    var ulist = $('#instagram-photo-holder-ul');
		 
			    $.each($.parseJSON(data), function(i, item){
			    	
			    	var img = document.createElement('img');
					img.src = item.images.standard_resolution.url;
					$(img).data('item', item);
					img.onclick = EventHelper.modifySelectedImage;
						    	
			    	ulist.append($(document.createElement('li').appendChild(img)));		    	
			    });
		    } else if(provider == 'twitter') {
		    	var ulist = $('#tweet-holder-ul');
		    	$.each($.parseJSON(data), function(i, item){
		    		var nDiv = document.createElement('div').innerHTML = item.text;
		    		ulist.append(nDiv);
		    	});
		    }		
	   }
	}).fail(function() {
		
	});
};

function showViewModel() {
	var self = this;
	
};

