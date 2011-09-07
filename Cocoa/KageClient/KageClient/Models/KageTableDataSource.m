//
//  KageTableDataSource.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageTableDataSource.h"
#import "Anime.h"
#import "AnimeCategory.h"
#import "AnimeView.h"
#import "CustomTableFlushViewCell.h"
#import "Three20Core/NSArrayAdditions.h"
#import "CoreDataHelper.h"

@implementation KageModel
@synthesize animeList = _animeList, shouldReload = _shouldReload;

- (void)invalidate:(BOOL)erase {
    
}

- (void)cancel {
    
}

- (BOOL)isOutdated {
    return _shouldReload;
}

- (BOOL)isLoading {
    return _loading;
}

- (BOOL)isLoadingMore {
    return NO;
}

- (BOOL)isLoaded {
    NSLog(@"model is %@ loaded", (!!_animeList && !_loading) ? @"" : @"NOT");
    return !!_animeList && !_loading;
}

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = TTCreateNonRetainingArray();
    }
    return _delegates;    
}

- (void)loadData:(Anime*)anime {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[CoreDataHelper persistentStoreCoordinator]];
    
    Anime* threadAnime = [Anime getAnime:anime.baseId managedObjectContext:moc];
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
        [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];   
        _shouldReload = NO;
    }
    
    [pool release];        
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    _loading = YES;
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
    
    if (!_animeList)
        _animeList = [[NSMutableArray alloc] init];    
    
    [_animeList removeAllObjects];
    [_animeList addObjectsFromArray:[Anime allAnime:[CoreDataHelper managedObjectContext]]];   
    
    if (!_loadedFlags) {
        _loadedFlags = [[NSMutableDictionary alloc] init];
    }
    
    for (Anime* anime in _animeList) {
        [_loadedFlags setObject:[NSNumber numberWithBool:NO] forKey:anime.name];
    }
    
    _loading = _animeList.count > 0;
    for (Anime* anime in _animeList) {
        [self performSelectorInBackground:@selector(loadData:) withObject:[anime retain]];
    }     
    
    if (!_loading)
        [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];   
}

@end

@implementation KageTableDataSource
@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        _kageModel = [[KageModel alloc] init];
        self.model = _kageModel;
    }
    return self;
}

- (id<TTModel>)model {
    return _kageModel;
}

- (void)dealloc {
    [_kageModel release];
    [super dealloc];
}

- (void)tableViewDidLoadModel:(UITableView *)tableView {
    if (!_items)
        _items = [[NSMutableArray alloc] init];

    [_items removeAllObjects];        
        
    NSMutableArray* viewsWithNew = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray* viewsWithOutNew = [[[NSMutableArray alloc] init] autorelease];
    for (Anime* anime in _kageModel.animeList) {
        //TableAnimeItem* item = [TableAnimeItem itemWithText:anime.name imageURL:nil defaultImage:[UIImage imageWithData:anime.image] URL:[NSString stringWithFormat:@"tt://details/%i", anime.baseId.integerValue]];
        //item.anime = anime;
        AnimeView* view = [[AnimeView alloc] initWithAnime:anime];        
        if (view.haveNew) 
            [viewsWithNew addObject:view];
        else
            [viewsWithOutNew addObject:view];
    }
    
    [_items addObjectsFromArray:viewsWithNew];
    [_items addObjectsFromArray:viewsWithOutNew];    
    
    if (_items.count == 0) {
        [_items addObject:[TTTableTextItem itemWithText:@"Добавить"]];
    }
}

- (void)updateNewLabels {
    for (int i = 0; i < _items.count; i++) {
        if ([[_items objectAtIndex:i] isKindOfClass:[AnimeView class]]) {
            AnimeView* view = [_items objectAtIndex:i];
            [view updateNewItems];
        }
    }
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[AnimeView class]])
        return [CustomTableFlushViewCell class];
    else
        return [super tableView:tableView cellClassForObject:object];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIView* cell = [_items objectAtIndex:indexPath.row]; 
        if ([cell isKindOfClass:[AnimeView class]]) {
            AnimeView* item = (AnimeView*)cell;
            
            if ([Anime removeAnime: item.anime managedObjectContext:[CoreDataHelper managedObjectContext]]) {
                [_items removeObject:item];
                if (_items.count == 0) {
                    [_items addObject:[TTTableTextItem itemWithText:@"Добавить"]];
                }
                [_delegate dataDidChanged:self];
            }                        
        }                      
    }    
}

- (void)addAnime:(NSNumber*)objId {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:[CoreDataHelper persistentStoreCoordinator]];
    
    if ([Anime addAnime:objId managedObjectContext:moc]) {        
        //_kageModel.shouldReload = YES;
        AnimeView* view = [[AnimeView alloc] initWithAnime:[Anime getAnime:objId managedObjectContext:moc]];
        if ([[_items objectAtIndex:0] isKindOfClass:[TTTableTextItem class]])
            [_items removeObjectAtIndex:0];

        [_items insertObject:view atIndex:0];
        [_delegate dataDidChanged:self];
    }        
    [pool release];
}

+ (id<TTTableViewDataSource>)dataSourceWithAnime {    
    KageTableDataSource* datasource = [[[KageTableDataSource alloc] init] autorelease];

    return datasource;
}

@end
