//
//  RegexHelper.h
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegexHelper : NSObject

+ (NSArray*)arrayWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern;

+ (NSString*)stringWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern;

+ (NSString*)stringWithHtmlTagContent:(NSString*)html tag:(NSString*)tag;

@end
