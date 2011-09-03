//
//  KageParser.h
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@interface KageParser : NSObject {
    NSString* _htmlBody;
    Anime* _anime;
}

@property(nonatomic, retain) Anime* anime;

- (id)initWithAnime:(Anime*)anime;

@end
