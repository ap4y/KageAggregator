//
//  AnimeView.h
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "Anime.h"

@interface AnimeView : UIView {
    
    Anime* _anime;
    TTLabel* newLabel;
}

@property(nonatomic, retain)Anime* anime;
@property(nonatomic, readonly)BOOL haveNew;

- (id)initWithAnime:(Anime*)anime;
- (void)updateNewItems;

@end
