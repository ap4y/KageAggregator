//
//  KageOSXAppDelegate.h
//  KageOSX
//
//  Created by Arthur Evstifeev on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KageOSXAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
