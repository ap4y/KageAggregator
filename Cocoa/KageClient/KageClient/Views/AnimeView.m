//
//  AnimeView.m
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimeView.h"
#import "AnimeCategory.h"
#import "Subtitle.h"

@implementation AnimeView
@synthesize anime = _anime;

- (id)initWithAnime:(Anime*)anime {

    self = [super initWithFrame:CGRectMake(0, 0, 320, 200)];
    if (self) {
        UIImage* image = [UIImage imageWithData:anime.image];
        
        self.frame = CGRectMake(0, 0, 320, image.size.height + 20);
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(320 - 140, 10, 140, image.size.height)];
        imageView.image = image;
        [self addSubview:imageView];
                
        UILabel* nameLabel = [[UILabel alloc] init];        
        nameLabel.text = anime.name;
        nameLabel.frame= CGRectMake(10, 10, 320 - 150, 40);        
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.font = (UIFont*)TTSTYLE(tableFont);
        [nameLabel adjustsFontSizeToFitWidth];
        [self addSubview:nameLabel];
                   
        NSNumber* maxSeries = [anime.subtitles valueForKeyPath:@"@max.seriesCount"];
        UILabel* countLabel = [[UILabel alloc] init];        
        countLabel.text = [NSString stringWithFormat:@"%@ серий", maxSeries.stringValue];
        countLabel.frame= CGRectMake(10, 40, 320 - 150, 30);        
        countLabel.textAlignment = UITextAlignmentCenter;
        countLabel.font = (UIFont*)TTSTYLE(messageFont);
        [self addSubview:countLabel];
        
        NSArray* updatedSubtitles = [anime subtitlesUpdated];         
        UILabel* newLabel = [[UILabel alloc] init];        
        newLabel.text = [NSString stringWithFormat:@"%i новых серий", updatedSubtitles.count];
        newLabel.frame= CGRectMake(10, 80, 320 - 150, 30);        
        newLabel.textAlignment = UITextAlignmentCenter;
        newLabel.font = (UIFont*)TTSTYLE(messageFont);
        newLabel.hidden = (updatedSubtitles.count == 0);
        //[self addSubview:newLabel];        
        
        UIButton* nextBtn = [[UIButton alloc] initWithFrame:self.frame];
        [nextBtn addTarget:self action:@selector(goToDetails:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextBtn];
        
        _anime = [anime retain];
        
        [nextBtn release];
        [newLabel release];
        [countLabel release];
        [nameLabel release];
        [imageView release];
    }
    return self;
}

- (void)goToDetails:(id)sender {
    NSLog(@"%@", _anime.baseId);
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://details/%i", _anime.baseId.integerValue]]];
}

@end
