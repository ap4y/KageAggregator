//
//  MainView.h
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnimeDatasource.h"
#import "Anime.h"
#import "AnimeCategory.h"

@interface MainView : NSViewController <NSTextFieldDelegate, NSTableViewDelegate, AnimeDatasourceDelegate> {
    AnimeDatasource* _dataSource;
    IBOutlet NSTextField *_idTextField;
    IBOutlet NSScrollView *_scrollView;
    Anime* _curAnime;
    IBOutlet NSArrayController *subtitlesController;
    IBOutlet NSTableView *_tableView;
    IBOutlet NSArrayController *_animeArrayController;
    IBOutlet NSCollectionView *_animeCollectionView;
}

@property(nonatomic, retain) AnimeDatasource* dataSource;
@property(nonatomic, retain, readonly) NSArray* selectedSubtitles;

- (IBAction)addAnime:(id)sender;
- (IBAction)removeAnime:(id)sender;
- (IBAction)refreshAnime:(id)sender;

@end
