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

+ (NSArray*)allAnime {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    
    return [CoreDataHelper requestResult:fetchRequest];
}

+ (Anime*)getAnime:(NSNumber*)baseId {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    //[fetchRequest setFetchBatchSize:20];
        
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"baseId == %i", baseId.integerValue];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestFirstResult:fetchRequest];
}

+ (BOOL)addAnime:(NSNumber*)baseId {
    
    if ([self getAnime:baseId]) {
        return NO;
    }            
    
    Anime* newAnime = [[Anime alloc] init];  
    newAnime.baseId = baseId;
            
    return [newAnime reloadAnime];
}

+ (BOOL)removeAnime:(Anime*)anime {
    [[CoreDataHelper managedObjectContext] deleteObject:anime];
    
    return [CoreDataHelper save];
}

- (BOOL)reloadAnime {
    KageParser* kageParser = [[[KageParser alloc] initWithAnime:self] autorelease];
    
    if (!kageParser)
        return NO;

    [kageParser reloadData];

    return [CoreDataHelper save];
}

- (void)setIsWatched {
    for (Subtitle* subtitle in self.subtitles.allObjects) {
        subtitle.updated = [NSNumber numberWithBool:NO];
    }        
    
    [CoreDataHelper save];
}

- (NSArray *)subtitlesBySeriesCount {
    NSSortDescriptor *sortDescriptorCount = [[[NSSortDescriptor alloc] initWithKey:@"seriesCount" ascending:YES] autorelease];
    
    return [self.subtitles sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorCount]];
}

- (id)init {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    self = [super initWithEntity:entity insertIntoManagedObjectContext:[CoreDataHelper managedObjectContext]];
    if (self) {
        
    }   
    return self;
}

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"srtId == %i AND anime == %@", srtId.integerValue, self];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestFirstResult:fetchRequest];
}

- (NSArray*)subtitlesUpdated {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
        
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"anime == %@ and updated = YES", self];
    [fetchRequest setPredicate:libraryPredicate];
    
    return [CoreDataHelper requestResult:fetchRequest];
}

@end
