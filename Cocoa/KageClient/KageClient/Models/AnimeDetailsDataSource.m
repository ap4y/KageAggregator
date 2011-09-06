//
//  AnimeDetailsDataSource.m
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeDetailsDataSource.h"
#import "Subtitle.h"
#import "Group.h"
#import "AnimeCategory.h"

@implementation AnimeDetailsDataSource
@synthesize anime = _anime;

- (void)dealloc {
    TT_RELEASE_SAFELY(_subtitlesArray);
    [super dealloc];
}

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath {
            
    Subtitle* curSub = [_subtitlesArray objectAtIndex:indexPath.row];
    if (curSub.updated.boolValue) {
        UIView* backView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        backView.backgroundColor = (UIColor*)TTSTYLE(updatedCellBackgroundColor);
        cell.backgroundView = backView;
    }
}

- (void)fillItems {
    NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
    
    if (!_subtitlesArray) {
        _subtitlesArray = [[NSMutableArray alloc] init];
    }
    [_subtitlesArray removeAllObjects];    
    [_subtitlesArray addObjectsFromArray:_anime.subtitlesBySeriesCount];
    
    for (Subtitle* subtitle in _subtitlesArray) {            
        [items addObject:[TTTableCaptionItem itemWithText:subtitle.fansubGroup.name caption:subtitle.seriesCount.stringValue]];
    }
    
    self.items = items;
}

+ (id<TTTableViewDataSource>)dataSourceWithSubtitles:(Anime*)anime {    
    AnimeDetailsDataSource* datasource = [[[AnimeDetailsDataSource alloc] init] autorelease];    
    datasource.anime = anime;
    [datasource fillItems];
    
    return datasource;
}

@end
