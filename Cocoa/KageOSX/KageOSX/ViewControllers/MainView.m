//
//  MainView.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "AnimeView.h"
#import "Subtitle.h"
#import "Group.h"
#import "GrowlNotificator.h"

@implementation MainView
@synthesize dataSource = _dataSource;

- (void)updateNotifications {
    //check for new items
    int newCount = 0;
    for (int i = 0; i < _animeCollectionView.content.count; i++) {
        AnimeView* animeView = (AnimeView*)[_animeCollectionView itemAtIndex:i];
        if (animeView.haveNew) {
            for (Subtitle* subtitle in animeView.anime.subtitlesUpdated) {
                [[GrowlNotificator sharedNotifier] growlAlert:[NSString stringWithFormat:@"%%i серия от %@", subtitle.seriesCount.integerValue, subtitle.fansubGroup.name] title:animeView.anime.name iconData: animeView.anime.image];
            }            
            newCount++;
        }
    }
    
    if (newCount > 0) {        
        [[NSApplication sharedApplication].dockTile setBadgeLabel:[NSString stringWithFormat:@"%i", newCount]];        
    }
    else
        [[NSApplication sharedApplication].dockTile setBadgeLabel:@""];
}

- (void)animeAtIndex:(int)itemNum {
    if (_dataSource.items.count == 0)
        [_tableScrollView setHidden:YES];
    else
        [_tableScrollView setHidden:NO];             
    
    if (itemNum >= _dataSource.items.count) {
        return;
    }
    
    //if (![_curAnime isEqual:[_dataSource.items objectAtIndex:itemNum]]) {                                

        _curAnime = (Anime*)[_dataSource.items objectAtIndex:itemNum];
        NSArray* subtitles = [_curAnime subtitlesBySeriesCount];
        [subtitlesController setContent: subtitles];
    
        NSMutableIndexSet* indexSet = [[[NSMutableIndexSet alloc] init] autorelease];
        for (int i = 0; i < subtitles.count; i++) {
            Subtitle* subtitle = [subtitles objectAtIndex:i];
            if (subtitle.updated.boolValue) {
                [indexSet addIndex:i];
            }
        }
    
        [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    //}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [[AnimeDatasource alloc] init];
        _dataSource.delegate = self;
        
        [_scrollView setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScrolled:) name:NSViewBoundsDidChangeNotification object:_scrollView];        
        
        [NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(refreshAnime:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self animeAtIndex:0];
}

- (void)dealloc {
    [_dataSource release];
    [super dealloc];
}

- (void)didScrolled:(NSNotification*)scrollNotification {    
    float itemFloat = _scrollView.documentVisibleRect.origin.y / 235.0;
    int itemNum = roundf(itemFloat);
    //NSLog(@"item num %f - %i", itemFloat, itemNum);
    
    if (itemNum >= 0 && itemNum != [_dataSource.items indexOfObject:_curAnime]) {    
        if (_curAnime)
            [_curAnime setIsWatched];
        
        NSUInteger prevIndex = [_dataSource.items indexOfObject:_curAnime];
        if (prevIndex != NSNotFound && prevIndex < _dataSource.items.count) {
            AnimeView* prevView = (AnimeView*)[_animeCollectionView itemAtIndex:prevIndex];
            [prevView updateNewItems];
        } 
        
        [self animeAtIndex:itemNum];
        [self updateNotifications];
    }
}

- (NSArray*)selectedSubtitles {
    if (!_curAnime)
        return nil;
    
    return [_curAnime subtitlesBySeriesCount];
}

- (IBAction)addAnime:(id)sender {
    [_idTextField setHidden:NO];
    [_idTextField becomeFirstResponder];
    
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if (fieldEditor.string.length > 0) {
        NSNumberFormatter* numFormat = [[[NSNumberFormatter alloc] init] autorelease];   
        [_dataSource performSelectorInBackground:@selector(addAnime:) withObject:[numFormat numberFromString:fieldEditor.string]];        
        [fieldEditor setString:@""];        
    }
    
    [_idTextField resignFirstResponder];
    [_idTextField setHidden:YES];
    
    return YES;
}

- (IBAction)removeAnime:(id)sender {
    if (_curAnime) {
        Anime* animeToRemove = _curAnime;
        _curAnime = nil;
        [_dataSource removeAnime:animeToRemove];                
    }
}

- (IBAction)refreshAnime:(id)sender {
    [_dataSource loadItems];
}

- (void)datasourceDidChanged:(AnimeDatasource *)dataSource {        
    [_animeArrayController setContent:_dataSource.items];
    
    int itemNum = roundf(_scrollView.documentVisibleRect.origin.y / 235.0);
    if (itemNum >= 0 && itemNum < _dataSource.items.count) {
        if (itemNum != [_dataSource.items indexOfObject:_curAnime])
            [self animeAtIndex: itemNum];
    }
    else
        [_tableScrollView setHidden:YES];      
    
    [self updateNotifications];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    Subtitle* _curSub = (Subtitle*)[subtitlesController.arrangedObjects objectAtIndex:row];    
    NSArray* split = [_curSub.fansubGroup.name componentsSeparatedByString:@"\n"];
    NSUInteger rowCnt = split.count;        
    
    return 17*(rowCnt-1);
}

@end
