//
//  CommonData.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonData.h"
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "KageParser.h"

@implementation CommonData

+ (NSArray*)allAnime {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    
    return [[CoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:nil];
}

+ (Anime*)getAnime:(NSNumber*)baseId {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [fetchRequest setEntity:entity];    
    //[fetchRequest setFetchBatchSize:20];
        
    NSPredicate* libraryPredicate = [NSPredicate predicateWithFormat:@"baseId == %i", baseId.integerValue];
    [fetchRequest setPredicate:libraryPredicate];
    
    NSError* err = nil;
    NSArray* result = [[CoreDataHelper managedObjectContext] executeFetchRequest:fetchRequest error:&err];
    
    if (result.count == 0 || err)
        return nil;
    
    return [result objectAtIndex:1];
}

+ (BOOL)addAnime:(NSNumber*)baseId {
      
    if ([self getAnime:baseId]) {
        return NO;
    }            

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    
    Anime* newAnime = [[Anime alloc] initWithEntity:entity insertIntoManagedObjectContext:[CoreDataHelper managedObjectContext]];  
    
    KageParser* kageParser = [[[KageParser alloc] initWithAnime:newAnime] autorelease];
    
    if (!kageParser) {
        return NO;
    }
    
    NSError *error = nil;
    if (![[CoreDataHelper managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@", error.localizedDescription);
        return NO;
    }
    
    return YES;
}

+ (BOOL)removeAnime:(Anime*)anime {
    [[CoreDataHelper managedObjectContext] deleteObject:anime];
    
    NSError *error = nil;
    if (![[CoreDataHelper managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@", error.localizedDescription);
        return NO;
    }    
    
    return YES;
}


@end
