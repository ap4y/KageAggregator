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

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"srtId == %i AND anime == %@", srtId.integerValue, self];
    [fetchRequest setPredicate:libraryPredicate];
    
    NSError* err = nil;
    NSArray* result = [[CoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&err];
    
    if (result.count == 0 || err)
        return nil;
    
    return [result objectAtIndex:0];
}

@end
