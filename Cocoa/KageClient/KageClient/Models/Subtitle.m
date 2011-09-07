//
//  Subtitle.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Subtitle.h"
#import "Anime.h"
#import "Group.h"
#import "CoreDataHelper.h"

@implementation Subtitle
@dynamic seriesCount;
@dynamic srtId;
@dynamic updated;
@dynamic anime;
@dynamic fansubGroup;

- (id)initWithmanagedObjectContext:(NSManagedObjectContext*)managedObjectContext  {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subtitle" inManagedObjectContext:managedObjectContext];
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    if (self) {

    }
    return self;
}

@end
