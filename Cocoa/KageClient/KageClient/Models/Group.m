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

- (id)init {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:[CoreDataHelper managedObjectContext]];
    if (self) {
        
    }
    return self;
}

@end
