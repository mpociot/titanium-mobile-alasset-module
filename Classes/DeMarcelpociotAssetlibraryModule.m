/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "DeMarcelpociotAssetlibraryModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "AssetsLibrary/AssetsLibrary.h"

@implementation DeMarcelpociotAssetlibraryModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"defc264a-b629-4903-91b9-a7c1354ed3d6";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"de.marcelpociot.assetlibrary";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
    fflush(stderr);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs
-(void)assetForUrl:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    id onasset       = [args objectForKey:@"assetCallback"];
    NSString *sUrl = [args objectForKey:@"url"];
    NSURL *url = [[NSURL alloc] initWithString:sUrl];
    
    ENSURE_STRING_OR_NIL(sUrl);
    
    RELEASE_TO_NIL(assetUrlCallback);
    assetUrlCallback  = [onasset retain];
    
    void (^assetForURLResultBlock)(ALAsset *) = ^(ALAsset *result)
    {
        if( result != nil )
        {
            ALAssetRepresentation *rep = [result defaultRepresentation];
            NSURL *url = [[result defaultRepresentation] url];
            NSString *sUrl = [url absoluteString];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                UIImage *largeimage;
                largeimage = [UIImage imageWithCGImage:iref];
                UIImage *thumbnail;
                thumbnail   = [UIImage imageWithCGImage:[result thumbnail]];
                NSDictionary *event = [NSDictionary 
                                       dictionaryWithObjectsAndKeys:
                                       [[[TiBlob alloc] initWithImage:largeimage] autorelease],
                                       @"image",
                                       [[[TiBlob alloc] initWithImage:thumbnail] autorelease],
                                       @"thumbnail",
                                       sUrl,
                                       @"url",
                                       nil];
                if (assetUrlCallback!=nil)
                {
                    [self _fireEventToListener:@"onAsset" withObject:event listener:assetUrlCallback thisObject:nil];
                }
            }
        }
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:url
             resultBlock:assetForURLResultBlock
            failureBlock:^(NSError *error){NSLog(@"assetForUrl: Failure");}];
    
    [library release];
}


-(void)groups:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    id ongroup       = [args objectForKey:@"groupCallback"];
    NSString *group = [args objectForKey:@"group"];
    ENSURE_STRING_OR_NIL(group);
    
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    if( group == nil ){
        group = @"all";
    }
    if( [group isEqualToString:@"savedPhotos"] ){
        groupTypes  = ALAssetsGroupSavedPhotos;
    } else if( [group isEqualToString:@"photoStream"] ){
        groupTypes  = ALAssetsGroupPhotoStream;
    } else if( [group isEqualToString:@"faces"] ){
        groupTypes  = ALAssetsGroupFaces;
    } else if( [group isEqualToString:@"all"] ){
        groupTypes  = ALAssetsGroupAll;
    }
    
    RELEASE_TO_NIL(groupCallback);
    groupCallback  = [ongroup retain];
    void (^assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil) {
            CGImageRef iref = [group posterImage];
            UIImage *poster;
            poster = [UIImage imageWithCGImage:iref];
            NSString * groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            
            
            NSDictionary *event = [NSDictionary 
                                   dictionaryWithObjectsAndKeys:
                                   groupName,
                                   @"group",
                                   [[[TiBlob alloc] initWithImage:poster] autorelease],
                                   @"posterImage",
                                   NUMINT([group numberOfAssets]),
                                   @"assets",
                                   nil];
            if (groupCallback!=nil)
            {
                [self _fireEventToListener:@"onGroup" withObject:event listener:groupCallback thisObject:nil];
            }
            
            
        }
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:groupTypes
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {}];
    [library release];
}


-(void)assets:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    id loaded       = [args objectForKey:@"assetCallback"];
    NSString *group = [args objectForKey:@"group"];
    ENSURE_STRING_OR_NIL(group);
    
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    if( group == nil ){
        group = @"savedPhotos";
    }
    if( [group isEqualToString:@"savedPhotos"] ){
        groupTypes  = ALAssetsGroupSavedPhotos;
    } else if( [group isEqualToString:@"photoStream"] ){
        groupTypes  = ALAssetsGroupPhotoStream;
    } else if( [group isEqualToString:@"faces"] ){
        groupTypes  = ALAssetsGroupFaces;
    } else if( [group isEqualToString:@"all"] ){
        groupTypes  = ALAssetsGroupAll;
    }
    
    RELEASE_TO_NIL(loadedCallback);
    loadedCallback  = [loaded retain];
    void (^assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if( result != nil )
                {
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    NSURL *url = [[result defaultRepresentation] url];
                    NSString *sUrl = [url absoluteString];
                    CGImageRef iref = [rep fullResolutionImage];
                    if (iref) {
                        UIImage *largeimage;
                        largeimage = [UIImage imageWithCGImage:iref];
                        UIImage *thumbnail;
                        thumbnail   = [UIImage imageWithCGImage:[result thumbnail]];
                        NSDictionary *event = [NSDictionary 
                                               dictionaryWithObjectsAndKeys:
                                               [[[TiBlob alloc] initWithImage:largeimage] autorelease],
                                               @"image",
                                               [[[TiBlob alloc] initWithImage:thumbnail] autorelease],
                                               @"thumbnail",
                                               NUMINT(index),
                                               @"index",
                                               sUrl,
                                               @"url",
                                               nil];
                        if (loadedCallback!=nil)
                        {
                            [self _fireEventToListener:@"onAsset" withObject:event listener:loadedCallback thisObject:nil];
                        }
                    }
                }
            }];
        }
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:groupTypes
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {}];
    [library release];
}

-(void)assetThumbnails:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    id onthumb       = [args objectForKey:@"thumbnailCallback"];
    NSString *group = [args objectForKey:@"group"];
    ENSURE_STRING_OR_NIL(group);
    int page        = [TiUtils intValue:[args objectForKey:@"page"] def:1] - 1;
    int perPage     = [TiUtils intValue:[args objectForKey:@"perPage"] def:25];
    
    int fromIndex   = page * perPage;
    int toIndex     = fromIndex + perPage;

    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    if( group == nil ){
        group = @"savedPhotos";
    }
    if( [group isEqualToString:@"savedPhotos"] ){
        groupTypes  = ALAssetsGroupSavedPhotos;
    } else if( [group isEqualToString:@"photoStream"] ){
        groupTypes  = ALAssetsGroupPhotoStream;
    } else if( [group isEqualToString:@"faces"] ){
        groupTypes  = ALAssetsGroupFaces;
    } else if( [group isEqualToString:@"all"] ){
        groupTypes  = ALAssetsGroupAll;
    }
    RELEASE_TO_NIL(thumbCallback);
    thumbCallback  = [onthumb retain];
    void (^assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if( result != nil )
                {
                    if( (index >= fromIndex) && (index <= toIndex) ){
                        NSURL *url = [[result defaultRepresentation] url];
                        NSString *sUrl = [url absoluteString];
                            UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                            NSDictionary *event = [NSDictionary 
                                                   dictionaryWithObjectsAndKeys:
                                                   [[[TiBlob alloc] initWithImage:thumbnail] autorelease],
                                                   @"thumbnail",
                                                   NUMINT(index),
                                                   @"index",
                                                   sUrl,
                                                   @"url",
                                                   nil];
                            if (thumbCallback!=nil)
                            {
                                [self _fireEventToListener:@"onThumbnail" withObject:event listener:thumbCallback thisObject:nil];
                            }
                    }
                }
            }];
        }
    };
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:groupTypes
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {}];
    [library release];
}

-(id)exampleProp
{
	// example property getter
	return images;
}
@end
