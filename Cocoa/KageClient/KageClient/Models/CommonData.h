//
//  CommonData.h
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@interface CommonData : NSObject

+ (NSArray*)allAnime;
+ (Anime*)getAnime:(NSNumber*)baseId;
+ (BOOL)addAnime:(NSNumber*)baseId;
+ (BOOL)removeAnime:(Anime*)anime;
@end
