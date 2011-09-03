//
//  TableAnimeItem.h
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "Anime.h"

@interface TableAnimeItem : TTTableRightImageItem {
    
    Anime* _anime;
}

@property(nonatomic, retain) Anime* anime;

@end
