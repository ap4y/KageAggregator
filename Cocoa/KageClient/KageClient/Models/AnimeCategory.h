//
//  AnimeCategory.h
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Anime.h"

@interface Anime (AnimeCategory)

+ (NSArray*)allAnime;
+ (Anime*)getAnime:(NSNumber*)baseId;
+ (BOOL)addAnime:(NSNumber*)baseId;
+ (BOOL)removeAnime:(Anime*)anime;

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId;
- (NSArray *)subtitlesBySeriesCount;
- (void)setIsWatched;
- (NSArray*)subtitlesUpdated;
- (BOOL)reloadAnime;
@end
