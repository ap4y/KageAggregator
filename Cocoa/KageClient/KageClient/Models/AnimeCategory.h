//
//  AnimeCategory.h
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Anime.h"

@interface Anime (AnimeCategory)

+ (NSArray*)allAnime:(NSManagedObjectContext*)managedObjectContext;
+ (Anime*)getAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (BOOL)addAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (BOOL)removeAnime:(Anime*)anime managedObjectContext:(NSManagedObjectContext*)managedObjectContext ;

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId;
- (NSArray *)subtitlesBySeriesCount;
- (void)setIsWatched;
- (NSArray*)subtitlesUpdated;
- (BOOL)reloadAnime;
@end
