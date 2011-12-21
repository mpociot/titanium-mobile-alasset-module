// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var module_assetlibrary = require('de.marcelpociot.assetlibrary');
Ti.API.info("module is => " + module_assetlibrary);
module_assetlibrary.assets({
	group:  "all",
	load: function(e){
		var image 		= e.image;
		var thumbnail	= e.thumbnail;
		var view	= Ti.UI.createImageView({
			image: thumbnail,
			top: 0,
			left: (e.index * 50),
			width: 50,
			height: 50
		});
		window.add(view);
	}
});