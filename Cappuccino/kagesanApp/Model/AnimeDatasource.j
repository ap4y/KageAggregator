//
//  AnimeDatasource.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import "Anime.j"

@implementation AnimeDatasource : CPObject {
    CPMutableArray _items @accessors(property=items);
    BOOL _loading;
    CPMutableDictionary _loadedFlags;
    id _delegate @accessors(property=delegate);
}

- (void)loadData:(CPNumber)baseId {
    var threadAnime = [Anime getAnime:baseId];
    [threadAnime reloadAnime];
    
    /*[_loadedFlags setObject:[CPNumber numberWithBool:YES] forKey:threadAnime.baseId];
    CPLog(@"%@, %@", threadAnime.name, _loadedFlags.allValues);

    var isLoadingCheck = NO;
    for (var num in _loadedFlags.allValues) {
        if (!num.boolValue) {
            isLoadingCheck = YES;
            break;
        }
    }    

    CPLog(@"is loading %@", isLoadingCheck ? @"YES" : @"NO");
    
    _loading = isLoadingCheck;       
    if (!_loading) {
        
    }*/
}

- (void)loadItems {
    _loading = YES;
    
    [_items removeAllObjects];         
    [_items addObjectsFromArray:[Anime allAnime]];
    
    /*CPLog("items count %i", [_items count]);
    for (var i = 0; i < [_items count]; i++) {
        var anime = [_items objectAtIndex: i];
        CPLog("anime %i", anime.baseId.intValue);
        [_loadedFlags setObject:[CPNumber numberWithBool:NO] forKey:[anime baseId]];
    }*/
    
    CPLog("loadedFlags %@", _loadedFlags);
    
    for (var i = 0; i < [_items count]; i++) {
        var anime = [_items objectAtIndex: i];
        [self loadData:anime.baseId];
    }
    
    [_items removeAllObjects];
    
    var viewsWithNew = [[CPMutableArray alloc] init];
    var viewsWithOutNew = [[CPMutableArray alloc] init];
    var allAnime = [Anime allAnime];
    for (var i = 0; i < [allAnime count]; i++) {
        var anime = [allAnime objectAtIndex:i];
        if ([[anime subtitlesUpdated] count] > 0) 
            [viewsWithNew addObject:anime];
        else
            [viewsWithOutNew addObject:anime];
    }
    
    [_items addObjectsFromArray:viewsWithNew];
    [_items addObjectsFromArray:viewsWithOutNew];  
    [_delegate datasourceDidChanged];
}

- (void)removeAnime:(Anime)anime {
    if ([Anime removeAnime: anime]) {
        [_items removeObject:anime];
        [_delegate datasourceDidChanged];
    } 
}

- (void)addAnime:(CPNumber)objId {
    CPLog("adding anime %@", objId);
    if ([Anime addAnime:objId]) {        
        var anime = [Anime getAnime:objId];
        [_items insertObject:anime atIndex:0];
        [_delegate datasourceDidChanged];
    }     
}

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _items = [[CPMutableArray alloc] init];
        _loadedFlags = [[CPMutableDictionary alloc] init];
        if([delegate respondsToSelector:@selector(datasourceDidChanged)])
            _delegate = delegate;
        [self loadItems];
    }
    
    return self;
}

@end
