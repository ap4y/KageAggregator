//
//  AnimeView.m
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeView.h"
#import "Anime.h"
#import "AnimeCategory.h"

@implementation AnimeView
@synthesize anime = _anime;

- (void)refreshObjects {
    [_name setStringValue:_anime.name];
    
    NSImage* img = [[[NSImage alloc] initWithData:_anime.image] autorelease];    
    [_image setImage:img];
    
    NSNumber* maxSeries = [_anime.subtitles valueForKeyPath:@"@max.seriesCount"];
    [_count setStringValue:[NSString stringWithFormat:@"переведено %@", maxSeries.stringValue]];
    
    NSArray* updatedSubtitles = [_anime subtitlesUpdated];
    [_new setTitle:[NSString stringWithFormat:@"%i %@", updatedSubtitles.count, updatedSubtitles.count == 1 ? @"новая" : @"новых"]];
    [_new sizeToFit];
    [_new setHidden:(updatedSubtitles.count == 0)];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [NSBundle loadNibNamed:@"AnimeView" owner:self];
    }
    return self;
}

- (void)setRepresentedObject:(id)representedObject {
    if ([representedObject isKindOfClass:[Anime class]]) {
        _anime = (Anime*)representedObject;
        NSLog(@"anime name: %@", _anime.name);
        [self refreshObjects];
    }
}

- (BOOL)haveNew {
    return !_new.isHidden;
}
@end
