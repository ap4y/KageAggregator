//
//  AnimeDetailViewController.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeDetailViewController.h"
#import "AnimeDetailsDataSource.h"
#import "AnimeCategory.h"

@implementation AnimeDetailViewController

- (void)createModel {
    if (_anime) {        
        self.dataSource = [AnimeDetailsDataSource dataSourceWithSubtitles:_anime];
    }
}

-( void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_anime setIsWatched];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO]; 
    [super viewWillAppear:animated];
}

- (id)initWithAnimeId:(int)baseId {
    self = [super init];
    if (self) {         
        _anime = [Anime getAnime:[NSNumber numberWithInt:baseId]];
        self.variableHeightRows = YES;
        self.title = _anime.name;
    }
    return self;
}

@end
