//
//  KageParser.h
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KageParser : NSObject {
    NSString* _htmlBody;
    NSString* _fansubGroup;
}

//+ (void)parseHtml:(NSString*)html;

- (id)initWithContent:(NSString*)page fansubGroup:(NSString*)group;
- (id)initWithContent:(NSString*)page;
- (id)initWithURL:(NSURL*)page fansubGroup:(NSString*)group;
- (id)initWithURL:(NSURL*)page;

@end
