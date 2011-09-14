@import "../Common/RLOfflineLocalStorage.j"
@import "../Common/KageParser.j"

@implementation Anime : CPObject {
    CPNumber baseId    @accessors;
    CPData   image     @accessors;
    CPString name      @accessors;
    CPMutableArray  subtitles @accessors;
    
    RLOfflineLocalStorage _localStorage;
}

- (id)init {
    self = [super init];
    if (self) {
        subtitles = [[CPMutableArray alloc] init];
        _localStorage = [[RLOfflineLocalStorage alloc] initWithName:@"kagesSanStorage" delegate:self];
    }
    return self;
}

- (void)dataStoreIsNotSupported
{
    alert("Your browser doesn\'t support offline localStorage.");
}

+ (CPArray)allAnime {
    var animeKeysString = [_localStorage getValueForKey:"animeKeys"];
    var animeKeys = [animeKeysString objectFromJSON];
    
    return [CPArray arrayWithArray: animeKeys];
}

+ (Anime)getAnime:(CPNumber)baseId {
    var animeString = [_localStorage getValueForKey:[baseId stringValue]];
    return [animeString objectFromJSON];
}

+ (BOOL)addAnime:(CPNumber)baseId {
    
    if ([self getAnime:baseId]) {
        return NO;
    }            
    
    var newAnime = [[Anime alloc] init];  
    newAnime.baseId = baseId;
    
    return [newAnime reloadAnime];
}

+ (void)removeAnime:(Anime)anime {
    [_localStorage removeValueForKey:[anime.baseId stringValue]];
}

- (void) saveAnime {
    [_localStorage setValue:[CPString JSONFromObject:self] forKey:[self.baseId stringValue]];
}

- (void)reloadAnime {
    var kageParser = [[KageParser alloc] initWithAnime:self];
    
    if (!kageParser)
        return NO;
    
    [kageParser reloadData];
    
    [self saveAnime];
}

- (Subtitle)subtitleWithSrtId:(CPNumber)srtId {    
    CPLog("Check when will be values!!!");
    var srtIdPredicate = [CPPredicate predicateWithFormat: "srtId == " + [srtId stringValue]];
    var result = [subtitles filteredArrayUsingPredicate: srtIdPredicate];
    
    if ([result count] > 0)
        return [result objectAtIndex:0];
    else
        return nil;
}

- (void)setIsWatched {
    for (var subtitle in self.subtitles) {
        [subtitle setUpdated:[CPNumber numberWithBool:NO]];        
    }        
    
    [self saveAnime];
}

- (CPArray)subtitlesBySeriesCount {
    var sortDescriptorCount = [[CPSortDescriptor alloc] initWithKey:@"seriesCount" ascending:YES]; 
    var subtitles = [self.subtitles sortedArrayUsingDescriptors:[CPArray arrayWithObject:sortDescriptorCount]];
    
    return subtitles;
}

- (CPArray)subtitlesUpdated {
    CPLog("Check when will be values!!!");
    var srtIdPredicate = [CPPredicate predicateWithFormat: "updated = YES"];
    var result = [subtitles filteredArrayUsingPredicate: srtIdPredicate];
    
    return result;
}

@end
