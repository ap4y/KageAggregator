@import "../Common/RLOfflineLocalStorage.j"
@import "../Common/KageParser.j"
@import "../Common/CP2JSCoder.j"
@import "../Common/CP2JSDecoder.j"

@implementation AnimeForSave : CPObject {
    CPNumber baseId    @accessors;
    CPString image     @accessors;
    CPString name      @accessors;
    //CPMutableArray  subtitles @accessors;        
}

- (id)initFromAnime:(Anime)anime {
    self = [super init];
    if (self) {
        self.baseId = anime.baseId;
        self.name = anime.name;
        self.image = anime.image;
        
        var subtitles = [[CPMutableArray alloc] init];
        for (var i = 0 ; i < [anime.subtitles count]; i++) {
            var subtitle = [anime.subtitles objectAtIndex:i];
            [subtitles addObject: subtitle.srtId];
        }
    }
    return self;
}

- (Anime)decodeAnime {
    var anime = [[Anime alloc] init];
    anime.baseId = self.baseId;
    anime.name = self.name;
    anime.image = self.image;
    
    var _localStorage = [[RLOfflineLocalStorage alloc] initWithName:[Anime kagesSanStorageName] delegate:self];
    for (var i = 0 ; i < [self.subtitles count]; i++) {
        var subtitle = [self.subtitles objectAtIndex:i];

        var subtitleFull = [_localStorage getValueForKey:[subtitle.srtId stringValue]];
        [anime.subtitle addObject: subtitleFull];
    }
    
    return anime;
}

@end

@implementation Anime : CPObject {
    CPNumber baseId    @accessors;
    CPString image     @accessors;
    CPString name      @accessors;
    CPMutableArray  subtitles @accessors;        
}

+ (CPString)kagesSanStorageName {
    return "kagesSanStorage";
}

- (id)init {
    self = [super init];
    if (self) {
        CPLog("anime is initializing");
        subtitles = [[CPMutableArray alloc] init];    
        CPLog("anime initialized");
    }
    return self;
}

- (void)dataStoreIsNotSupported
{
    alert("Your browser doesn\'t support offline localStorage.");
}

+ (CPArray)allAnimeKeys {
    var _localStorage = [[RLOfflineLocalStorage alloc] initWithName:[Anime kagesSanStorageName] delegate:self];
    var animeKeysString = [_localStorage getValueForKey:"animeKeys"];
    
    if (animeKeysString != nil) {
        CPLog("animeKeysString %@ found", animeKeysString);    
        
        return [CPArray arrayWithArray: [animeKeysString objectFromJSON]];
    }
    
    return nil;
}

+ (CPArray)allAnime {
    var animeKeys = [Anime allAnimeKeys];
    CPLog("animeKeys count %@", [animeKeys count]);
    
    if (animeKeys != nil) {
        var result = [[CPMutableArray alloc] init];
        for (var i = 0; i < [animeKeys count]; i++) {
            animeKey = [animeKeys objectAtIndex: i];
            CPLog("animeKey %@ found", animeKey);
            
            [result addObject: [Anime getAnime: animeKey]];
        }
        
        CPLog("found %i anime", [result count]);
        return result;
    }
    return nil;
}

+ (Anime)getAnime:(CPNumber)baseId {
    var _localStorage = [[RLOfflineLocalStorage alloc] initWithName:[Anime kagesSanStorageName] delegate:self];    
    var animeString = [_localStorage getValueForKey:[baseId stringValue]];
    
    animeString = JSON.parse(animeString);
    if (animeString != nil) {        
        CPLog("animeString: %@", animeString);
        var result = [CP2JSDecoder decodeRootJSObject:animeString];
        CPLog("decoded object is %@", result);
        
        return result;
    }
    
    return nil;
}

+ (BOOL)addAnime:(CPNumber)baseId {
    CPLog("searching dublicate anime %@", [baseId stringValue]);
    
    if ([Anime getAnime:baseId]) {
        return NO;
    }            
    
    CPLog("anime with same baseId not found");
    
    var newAnime = [[Anime alloc] init];  
    newAnime.baseId = baseId;
    
    CPLog("new anime is creating with baseID", [newAnime.baseId stringValue]);
    
    return [newAnime reloadAnime];
}

+ (BOOL)removeAnime:(Anime)anime {
    var _localStorage = [[RLOfflineLocalStorage alloc] initWithName:[Anime kagesSanStorageName] delegate:self];
    [_localStorage removeValueForKey:[anime.baseId stringValue]];

    var animeKeys = [Anime allAnimeKeys];
    CPLog("animeKeys count %@", [animeKeys count]);
    
    if (animeKeys == nil) {
        return NO;
    }
    
    if ([animeKeys containsObject: anime.baseId]) {
        [animeKeys removeObject: anime.baseId];
        [_localStorage setValue:[CPString JSONFromObject: animeKeys] forKey:"animeKeys"];
        CPLog("animeKey saved %@", [[anime baseId] stringValue]);    
    } 
    
    return YES;
}

- (void)saveAnime {
    var _localStorage = [[RLOfflineLocalStorage alloc] initWithName:[Anime kagesSanStorageName] delegate:self];
    CPLog("Recieved local storage: %@", self);
    
    var argumentJSObject = [CP2JSCoder encodeRootObjectToJS:self]; // also works for primitives
    CPLog("json object:", argumentJSObject);
    
    argumentValue = JSON.stringify(argumentJSObject);    
    [_localStorage setValue: argumentValue forKey:[self.baseId stringValue]];
    CPLog("anime saved %@", argumentValue);
    
    var animeKeys = [Anime allAnimeKeys];
    CPLog("animeKeys count %@", [animeKeys count]);
    
    if (animeKeys == nil) {
        animeKeys = [[CPMutableArray alloc] init];
    }
    if (![animeKeys containsObject: self.baseId]) {
        [animeKeys addObject: self.baseId];
        [_localStorage setValue:[CPString JSONFromObject: animeKeys] forKey:"animeKeys"];
        CPLog("animeKey saved %@", [[self baseId] stringValue]);    
    }    
}

- (BOOL)reloadAnime {
    var kageParser = [[KageParser alloc] initWithAnime:self];
    
    if (!kageParser)
        return NO;
    
    CPLog("kageParser is ready");
    [kageParser reloadData];

    CPLog("kageParser is done");
    [self saveAnime];
    
    return YES;
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
    /*var updSubs = [self subtitlesUpdated];
    for (var i = 0; i < [updSubs count]; i++) {
        var subtitle = [updSubs objectAtIndex:i];        
        subtitle.updated = NO;
    }        
    
    CPLog("anime will be saved");*/
    
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
