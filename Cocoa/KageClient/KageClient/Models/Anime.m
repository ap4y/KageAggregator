//
//  Anime.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Anime.h"
#import "Subtitle.h"
#import "CoreDataHelper.h"

@implementation Anime
@dynamic baseId;
@dynamic image;
@dynamic name;
@dynamic subtitles;

- (NSArray*)allAnime {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    
    return [CoreDataHelper requestResult:fetchRequest];
}

@end
