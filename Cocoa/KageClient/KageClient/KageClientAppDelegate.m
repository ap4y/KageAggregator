//
//  KageClientAppDelegate.m
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageClientAppDelegate.h"
#import "KageParser.h"
#import "StyleSheet.h"

@implementation KageClientAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    [TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
    
    TTNavigator* navigator = [TTNavigator navigator];
    navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = self.window;
    TTURLMap* map = navigator.URLMap;
    [map from:@"tt://animelist/" toSharedViewController:NSClassFromString(@"KageTableViewController")];
    [map from:@"tt://details/(initWithAnimeId:)" toViewController:NSClassFromString(@"AnimeDetailViewController")];
    
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://animelist/"]];    
        
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
