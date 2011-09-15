/*
 * AppController.j
 * kagesanApp
 *
 * Created by You on September 12, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "ViewControllers/MainView.j"

@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    @outlet CPView _content;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var _mainViewController = [[MainView alloc] initWithCibName:"MainView" bundle:nil];
    [_content addSubview: [_mainViewController view]]
    
    var path = [[CPBundle mainBundle] pathForResource:"bg.jpg"];
	backImg = [[CPImage alloc] initWithContentsOfFile:path size:CGSizeMake(200, 200)];
    CPLog("image length %@", [backImg size]);
    [[_mainViewController view] setBackgroundColor:[CPColor colorWithCSSString:"rgb(246,246,246)"]] 
    [[theWindow contentView] setBackgroundColor:[CPColor colorWithPatternImage:backImg]] 
    //[[theWindow contentView] addSubview: [_mainViewController view]];       
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
