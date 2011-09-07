//
//  KageOSXAppDelegate.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageOSXAppDelegate.h"
#import "MainView.h"

@implementation KageOSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    MainView* _mainViewController = [[MainView alloc] initWithNibName:@"MainView" bundle:nil];
    [hudWindow.contentView addSubview:_mainViewController.view];    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (flag) {
        return NO;
    } else {
        if (hudWindow) {
            [hudWindow orderFront:self];   
        }        
        return YES;
    }	
}
@end
