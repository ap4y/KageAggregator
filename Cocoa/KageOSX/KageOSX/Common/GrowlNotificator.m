//
//  GrowlNotificator.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 08.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GrowlNotificator.h"

@implementation GrowlNotificator

+ (GrowlNotificator*)sharedNotifier {
    static GrowlNotificator *sharedNotifier;
    
    @synchronized(self)
    {
        if (!sharedNotifier) {
            sharedNotifier = [[GrowlNotificator alloc] init];    
        }
        
        return sharedNotifier;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    
    return self;
}

- (NSDictionary *)registrationDictionaryForGrowl {
    NSArray *array = [NSArray arrayWithObjects:@"NewAnime", nil]; 
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1],
                          @"TicketVersion", 
                          array, 
                          @"AllNotifications", 
                          array,
                          @"DefaultNotifications",
                          nil];
    return dict;
}

- (void)growlAlert:(NSString *)message title:(NSString *)title iconData:(NSData*)iconData {
    [GrowlApplicationBridge notifyWithTitle:title 
                                description:message 
                           notificationName:@"NewAnime"
                                   iconData:iconData
                                   priority:0 
                                   isSticky:NO
                               clickContext:nil]; 
}

@end
