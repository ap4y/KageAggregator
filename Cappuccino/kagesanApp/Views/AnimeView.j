//
//  AnimeView.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import "../Model/Anime.j"

@implementation AnimeView : CPCollectionViewItem {
    Anime _anime @accessors(property=anime);
    @outlet CPTextField _name;
    @outlet CPImageView _image;
    @outlet CPTextField _count;
    @outlet CPButton _new;

    BOOL haveNew @accessors;
}

- (void)refreshObjects {
    [_name setStringValue:_anime.name];
    
    var img = [[CPImage alloc] initWithContentsOfFile:_anime.image];    
    [_image setImage:img];
    
    var maxSeries = [_anime.subtitles valueForKeyPath:@"@max.seriesCount"];
    [_count setStringValue:[CPString stringWithFormat:@"переведено %@", maxSeries]];
    
    var updatedSubtitles = [_anime subtitlesUpdated];
    [_new setTitle:[CPString stringWithFormat:@"%i %@", [updatedSubtitles count], [updatedSubtitles count] == 1 ? @"новая" : @"новых"]];
    [_new sizeToFit];
    [_new setHidden:([updatedSubtitles count] == 0)];
}

- (id)initWithCoder:(CPCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        CPLog("should load cib");
        [CPBundle loadCibNamed:@"AnimeView" owner:self];
    }
    return self;
}


- (void)setRepresentedObject:(id)representedObject {
    CPLog(@"should present object: %@", representedObject);
    if ([representedObject isKindOfClass: [Anime class]]) {
        _anime = representedObject;
        CPLog(@"anime name: %@", _anime.name);
        [self refreshObjects];
    }
}

- (BOOL)haveNew {
    return !_new.isHidden;
}

- (void)updateNewItems {
    var updatedSubtitles = [_anime subtitlesUpdated];
    CPLog(@"new subs count: %lu", [updatedSubtitles count]);
    [_new setHidden:([updatedSubtitles count] == 0)];
}

@end
