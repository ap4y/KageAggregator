//
//  AnimeCategory.m
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeCategory.h"
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "KageParser.h"
#import "Subtitle.h"

@implementation Anime (AnimeCategory)

+ (NSArray*)allAnime:(NSManagedObjectContext*)managedObjectContext {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];    
    
    return [CoreDataHelper requestResult:fetchRequest managedObjectContext:managedObjectContext];
}

+ (Anime*)getAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext: managedObjectContext];
    [fetchRequest setEntity:entity];    
    //[fetchRequest setFetchBatchSize:20];
        
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"baseId == %i", baseId.integerValue];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestFirstResult:fetchRequest managedObjectContext:managedObjectContext];
}

+ (BOOL)addAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    
    if ([self getAnime:baseId managedObjectContext:managedObjectContext]) {
        return NO;
    }            
    
    Anime* newAnime = [[Anime alloc] initWithmanagedObjectContext:managedObjectContext];  
    newAnime.baseId = baseId;
            
    return [newAnime reloadAnime];
}

+ (BOOL)removeAnime:(Anime*)anime managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    [managedObjectContext deleteObject:anime];
    
    return [CoreDataHelper save:managedObjectContext];
}

- (BOOL)reloadAnime {
    KageParser* kageParser = [[[KageParser alloc] initWithAnime:self] autorelease];
    
    if (!kageParser)
        return NO;

    [kageParser reloadData];

    return [CoreDataHelper save: self.managedObjectContext];
}

- (void)setIsWatched {
    for (Subtitle* subtitle in self.subtitles.allObjects) {
        subtitle.updated = [NSNumber numberWithBool:NO];
    }        
    
    [CoreDataHelper save:self.managedObjectContext];
}

- (NSArray *)subtitlesBySeriesCount {
    NSSortDescriptor *sortDescriptorCount = [[[NSSortDescriptor alloc] initWithKey:@"seriesCount" ascending:YES] autorelease];
    
    NSArray* subtitles = [self.subtitles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorCount]];
    
    return subtitles;
}

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];    
    
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"srtId == %i AND anime == %@", srtId.integerValue, self];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestFirstResult:fetchRequest managedObjectContext:self.managedObjectContext];
}

- (NSArray*)subtitlesUpdated {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];    
        
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"anime == %@ and updated = YES", self];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestResult:fetchRequest managedObjectContext:self.managedObjectContext];
}

@end
