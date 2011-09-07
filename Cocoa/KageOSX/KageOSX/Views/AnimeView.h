//
//  AnimeView.h
//  KageOSX
//
//  Created by Arthur Evstifeev on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@interface AnimeView : NSCollectionViewItem {
    Anime* _anime;
    IBOutlet NSTextField* _name;
    IBOutlet NSImageView* _image;
    IBOutlet NSTextField* _count;
    IBOutlet NSButton* _new;
}

@property(nonatomic, retain) Anime* anime;
@property(nonatomic, readonly)BOOL haveNew;

@end
