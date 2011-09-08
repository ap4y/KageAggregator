//
//  GrowlNotificator.h
//  KageOSX
//
//  Created by Arthur Evstifeev on 08.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl-WithInstaller/GrowlApplicationBridge.h>

@interface GrowlNotificator : NSObject <GrowlApplicationBridgeDelegate>

+ (GrowlNotificator*)sharedNotifier;
- (void)growlAlert:(NSString *)message title:(NSString *)title iconData:(NSData*)iconData;

@end
