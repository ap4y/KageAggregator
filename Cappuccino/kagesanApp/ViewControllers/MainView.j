//
//  MainView.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import "../Views/AnimeView.j"
@import "../Model/Anime.j"
@import "../Model/Subtitle.j"
@import "../Model/AnimeDatasource.j"

@implementation MainView : CPViewController {
    AnimeDatasource _dataSource @accessors(property=dataSource);
    @outlet CPTextField _idTextField;
    @outlet CPScrollView _scrollView;
    Anime  _curAnime;
    @outlet CPArrayController subtitlesController;
    @outlet CPTableView _tableView;
    @outlet CPArrayController _animeArrayController;
    @outlet CPCollectionView _animeCollectionView;
    @outlet CPScrollView _tableScrollView;
    @outlet CPButton _btnRefresh;
    CPArray selectedSubtitles;
}


 - (void)updateNotifications {
/*    
    //check for new items
    int newCount = 0;
    for (int i = 0; i < _animeCollectionView.content.count; i++) {
        AnimeView* animeView = (AnimeView*)[_animeCollectionView itemAtIndex:i];
        if (animeView.haveNew) {
            for (Subtitle* subtitle in animeView.anime.subtitlesUpdated) {
                [[GrowlNotificator sharedNotifier] growlAlert:[NSString stringWithFormat:@"%i серия от %@", subtitle.seriesCount.integerValue, subtitle.fansubGroup.name] title:animeView.anime.name iconData: animeView.anime.image];
            }            
            newCount++;
        }
    }    
*/
}

- (void)animeAtIndex:(int)itemNum {
    CPLog("_dataSource items count %i", [[_dataSource items] count]);
    
    if ([[_dataSource items] count] == 0)
        [_tableScrollView setHidden:YES];
    else
        [_tableScrollView setHidden:NO];             
    
    if (itemNum >= [[_dataSource items] count]) {
        return;
    }
    
    _curAnime = [[_dataSource items] objectAtIndex:itemNum];
    var subtitles = [_curAnime subtitlesBySeriesCount];
    [subtitlesController setContent: subtitles];

    var indexSet = [CPMutableIndexSet indexSet];
    for (var i = 0; i < [subtitles count]; i++) {
        var subtitle = [subtitles objectAtIndex:i];
        if ([subtitle.updated boolValue]) {
            //CPLog("index added");
            [indexSet addIndex:i];
        }
    }

    if ([indexSet isEqual: [CPMutableIndexSet indexSet]])
        [_tableView deselectAll];
    else
        [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (id)initWithCibName:(CPString)aCibNameOrNil bundle:(CPBundle)aCibBundleOrNil
{
    self = [super initWithCibName:aCibNameOrNil bundle:aCibBundleOrNil];
    if (self) {
        _dataSource = [[AnimeDatasource alloc] initWithDelegate: self];

        //[NSTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(refreshAnime:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];        
}

- (void)awakeFromCib {    
    CPLog("awakeFromCib");
    [_animeArrayController setContent: [_dataSource items]];
    
    [[_scrollView contentView] setPostsBoundsChangedNotifications: YES];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didScrolled:) name:CPViewBoundsDidChangeNotification object:[_scrollView contentView]];
        
    [self animeAtIndex:0];    
    
    var imgRefresh = [[CPImage alloc] initWithContentsOfFile:"Resources/NSRefreshTemplate.png" size:CGSizeMake(13, 13)];
    [_btnRefresh setImage: imgRefresh];
}

- (int)round:(float)floatVal {
    return Math.round(floatVal);
}

- (void)didScrolled:(CPNotification)scrollNotification {    
    //CPLog("didScrolled");    
    
    if ([[_scrollView contentView] visibleRect] != nil) {
        var itemFloat = [[_scrollView contentView] visibleRect].origin.y / 235.0;
        var itemNum = [self round: itemFloat];
        //CPLog(@"item num %f - %i; %@", itemFloat, itemNum, [[_dataSource items] indexOfObject:_curAnime] == itemNum ? "YES" : "NO" );
        
        if (itemNum >= 0 && itemNum != [[_dataSource items] indexOfObject:_curAnime]) {    
            CPLog("new item");
            
            if (_curAnime != nil) {                
                [_curAnime setIsWatched];                    
            }
            
            CPLog("marked as watched");
            var prevIndex = [[_dataSource items] indexOfObject:_curAnime];
            CPLog("prevItem item %i", prevIndex);
            
            if (prevIndex != CPNotFound && prevIndex < [[_dataSource items] count]) {
                CPLog("should update");
                var prevView = [_animeCollectionView itemAtIndex:prevIndex];
                [prevView updateNewItems];
                CPLog("updated");
            } 
            
            [self animeAtIndex:itemNum];
            [self updateNotifications];
        }

    }
}

- (CPArray)selectedSubtitles {
    if (_curAnime == nil)
        return nil;
    
    return [_curAnime subtitlesBySeriesCount];
}

- (IBAction)addAnime:(id)sender {
    [_idTextField setHidden:NO];
    [_idTextField becomeFirstResponder];    
}

- (void)controlTextDidEndEditing:(CPNotification)note {
    CPLog("controlTextDidEndEditing with count %@", [_idTextField objectValue]);
    if ([[_idTextField objectValue] length] > 0) {
        var numFormat = [[CPNumberFormatter alloc] init];   
        [_dataSource addAnime:[numFormat numberFromString:[_idTextField objectValue]]];        
        [_idTextField setObjectValue:@""];        
    }
    
    [_idTextField resignFirstResponder];
    [_idTextField setHidden:YES];
    
    return YES;
}

- (IBAction)removeAnime:(id)sender {
    if (_curAnime) {
        var animeToRemove = _curAnime;
        _curAnime = nil;
        [_dataSource removeAnime:animeToRemove];                
    }
}

- (IBAction)refreshAnime:(id)sender {
    [[_scrollView contentView] scrollToPoint:CPMakePoint(0, 0)];
    [_scrollView reflectScrolledClipView: [_scrollView contentView]];
    [_dataSource loadItems];
}

- (void)datasourceDidChanged {   
    CPLog("datasourceDidChanged");
    [_tableView selectRowIndexes:[CPIndexSet indexSet] byExtendingSelection:NO];
    [_animeArrayController setContent:[_dataSource items]];
    
    if ([[_scrollView contentView] visibleRect] != nil) {
        CPLog("y value: %@", [_scrollView visibleRect].origin.y);
        var itemFloat = [[_scrollView contentView] visibleRect].origin.y / 235.0;
        var itemNum = [self round: itemFloat];
        
        if (itemNum >= 0 && itemNum < [[_dataSource items] count]) {
            if (itemNum != [[_dataSource items] indexOfObject:_curAnime]) {
                [self animeAtIndex: itemNum];
            }
        }
        else {
            CPLog("_dataSource items count %i, %i", [[_dataSource items] count], itemNum);
            [_tableScrollView setHidden:YES];      
        }
        
        [self updateNotifications];
    }
}

- (float)tableView:(CPTableView)tableView heightOfRow:(int)row {
    var _curSub = [[subtitlesController arrangedObjects] objectAtIndex:row];    
    var split = [_curSub.fansubGroup componentsSeparatedByString:@"\n"];
    var rowCnt = [split count];        
    //CPLog("Setting row height for %@", _curSub.fansubGroup);
    
    return 17*(rowCnt-1);
}

@end
