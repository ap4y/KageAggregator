//
//  KageClientAppDelegate.m
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageClientAppDelegate.h"
#import "KageParser.h"

@implementation KageClientAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    NSError* err = nil;
    NSString* fileUrl = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"test.html"];
    //NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://fansubs.ru/base.php?id=3302"] encoding:NSWindowsCP1251StringEncoding error:&err];
    NSString* html = [NSString stringWithContentsOfFile:fileUrl encoding:NSWindowsCP1251StringEncoding error:&err];

    if (err)
        NSLog(@"getting string error %@", err.localizedDescription);
    
    KageParser* kageParser = [[KageParser alloc] initWithContent:html];    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
