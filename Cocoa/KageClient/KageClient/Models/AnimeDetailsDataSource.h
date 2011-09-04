//
//  AnimeDetailsDataSource.h
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "Anime.h"

@interface AnimeDetailsDataSource : TTListDataSource {
    
    Anime* _anime;
    NSMutableArray* _subtitlesArray;
}

@property(nonatomic, retain)Anime* anime;

+ (id<TTTableViewDataSource>)dataSourceWithSubtitles:(Anime*)anime;

@end
