//
//  Group.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Group.h"
#import "Subtitle.h"
#import "CoreDataHelper.h"

@implementation Group
@dynamic name;
@dynamic subtitle;

- (id)initWithmanagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext];
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    if (self) {
        
    }
    return self;
}

@end
