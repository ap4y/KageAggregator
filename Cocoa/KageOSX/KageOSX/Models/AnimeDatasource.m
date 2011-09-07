//
//  AnimeDatasource.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeDatasource.h"
#import "AnimeCategory.h"
#import "CoreDataHelper.h"

@implementation AnimeDatasource
@synthesize items = _items, delegate = _delegate;

- (void)loadData:(NSNumber*)baseId {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[CoreDataHelper persistentStoreCoordinator]];

    Anime* threadAnime = [Anime getAnime:baseId managedObjectContext:moc];
    [threadAnime reloadAnime];
    
    [_loadedFlags setObject:[NSNumber numberWithBool:YES] forKey:threadAnime.name];
    
    //NSLog(@"%@, %@", anime.name, _loadedFlags.allValues);
    
    BOOL isLoadingCheck = NO;
    for (NSNumber* num in _loadedFlags.allValues) {
        if (!num.boolValue) {
            isLoadingCheck = YES;
            break;
        }
    }
    
    _loading = isLoadingCheck;       
    if (!_loading) {
        [self performSelectorOnMainThread:@selector(postDidChangedNotification) withObject:nil waitUntilDone:NO];
    }
    
    [pool release];        
}

- (void)loadItems {
    _loading = YES;
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:[Anime allAnime:[CoreDataHelper managedObjectContext]]];     
    
    for (Anime* anime in _items) {
        [_loadedFlags setObject:[NSNumber numberWithBool:NO] forKey:anime.name];
    }
    
    for (Anime* anime in _items) {
        [self performSelectorInBackground:@selector(loadData:) withObject:anime.baseId];
    }
}

- (void)removeAnime:(Anime*)anime {
    if ([Anime removeAnime: anime managedObjectContext:[CoreDataHelper managedObjectContext]]) {
        [_items removeObject:anime];
        [_delegate datasourceDidChanged:self];
    } 
}

- (void)addAnime:(NSNumber*)objId {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[CoreDataHelper persistentStoreCoordinator]];
    
    if ([Anime addAnime:objId managedObjectContext:moc]) {        
        Anime* anime = [Anime getAnime:objId managedObjectContext:moc];
        [_items insertObject:anime atIndex:0];
        [self performSelectorOnMainThread:@selector(postDidChangedNotification) withObject:nil waitUntilDone:NO];
    }     
    [pool release];
}

- (void)postDidChangedNotification {
    [_delegate datasourceDidChanged:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        [self loadItems];
    }
    
    return self;
}

@end
