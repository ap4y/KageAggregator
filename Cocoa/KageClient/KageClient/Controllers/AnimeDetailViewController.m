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
#import "CoreDataHelper.h"

@implementation AnimeDetailViewController

- (void)createModel {
    if (_anime) {        
        self.dataSource = [AnimeDetailsDataSource dataSourceWithSubtitles:_anime];
    }
}

-( void)viewWillDisappear:(BOOL)animated {    
    [super viewWillDisappear:animated];
    [_anime setIsWatched];
    //[self.navigationController setNavigationBarHidden:YES];  
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:NO]; 
    [super viewWillAppear:animated];
}

- (id)initWithAnimeId:(int)baseId {
    self = [super init];
    if (self) {         
        _anime = [Anime getAnime:[NSNumber numberWithInt:baseId] managedObjectContext:[CoreDataHelper managedObjectContext]];
        self.variableHeightRows = YES;
        self.title = _anime.name;
    }
    return self;
}

@end
