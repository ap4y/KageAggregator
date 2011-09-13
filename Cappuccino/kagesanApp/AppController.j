/*
 * AppController.j
 * kagesanApp
 *
 * Created by You on September 12, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "Model/Anime.j"
@import "Common/KageParser.j"

@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLog("Creating anime");
    var anime = [[Anime alloc] init];
    anime.baseId = 123;
    CPLog("Anime created " + anime.baseId);
    
    CPLog("Creating parser");
    var kageParser = [[KageParser alloc] initWithAnime: anime];
    [kageParser reloadData];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.

    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullPlatformWindow:YES];
}

@end
