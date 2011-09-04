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
    NSLog(@"model is %@ loaded", !!_animeList ? @"" : @"NOT");
    return !!_animeList;
}

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = TTCreateNonRetainingArray();
    }
    return _delegates;    
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    _loading = YES;
    [_delegates perform:@selector(modelDidStartLoad:) withObject:self];
    
    if (!_animeList)
        _animeList = [[NSMutableArray alloc] init];    
    
    [_animeList removeAllObjects];
    [_animeList addObjectsFromArray:[Anime allAnime]];
    for (Anime* anime in _animeList) {
        [anime reloadAnime];
    }
    
    [_delegates perform:@selector(modelDidFinishLoad:) withObject:self];
    _loading = NO;
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
    [_items addObject:[TTTableTextItem itemWithText:@"Добавить"]];
        
    for (Anime* anime in _kageModel.animeList) {
        //TableAnimeItem* item = [TableAnimeItem itemWithText:anime.name imageURL:nil defaultImage:[UIImage imageWithData:anime.image] URL:[NSString stringWithFormat:@"tt://details/%i", anime.baseId.integerValue]];
        //item.anime = anime;
        AnimeView* view = [[AnimeView alloc] initWithAnime:anime];        
        [_items addObject:view];
    }
}

- (void)updateNewLabels {
    for (int i = 1; i < _items.count; i++) {
        AnimeView* view = [_items objectAtIndex:i];
        [view updateNewItems];
    }
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[AnimeView class]])
        return [CustomTableFlushViewCell class];
    else
        return [super tableView:tableView cellClassForObject:object];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIView* cell = [_items objectAtIndex:indexPath.row]; 
        if ([cell isKindOfClass:[AnimeView class]]) {
            AnimeView* item = (AnimeView*)cell;
            
            if ([Anime removeAnime: item.anime]) {
                [_items removeObject:item];
                [_delegate dataDidChanged:self];
            }                        
        }                      
    }    
}

- (void)addAnime:(NSNumber*)objId {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if ([Anime addAnime:objId]) {        
        _kageModel.shouldReload = YES;
        [_delegate dataDidChanged:self];
    }        
    [pool release];
}

+ (id<TTTableViewDataSource>)dataSourceWithAnime {    
    KageTableDataSource* datasource = [[[KageTableDataSource alloc] init] autorelease];

    return datasource;
}

@end
