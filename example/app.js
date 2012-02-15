var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var assetManager = require('de.marcelpociot.assetlibrary');
assetManager.assetThumbnails({
			page: 1,
			perPage: 1000,
			group:  "all",
			thumbnailCallback: function(e){
				var assets = e.assets;
				for( var i=0,max=assets.length; i<max; i++ ){
					var asset 		= assets[i];
					var thumbnail	= asset.thumbnail;
					var view	= Ti.UI.createImageView({
						image: thumbnail,
						top: 0,
						left: (e.index * 50),
						width: 50,
						height: 50
					});
					window.add(view);
					
					// To get the large image:
					assetManager.assetForUrl({
						url: _url,
						assetCallback: function(e){
							var largeImage = e.image;	
						}
					});
				}
			}
});