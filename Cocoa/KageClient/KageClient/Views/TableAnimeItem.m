//
//  TableAnimeItem.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableAnimeItem.h"

@implementation TableAnimeItem
@synthesize anime = _anime;

+ (id)itemWithText:(NSString *)text imageURL:(NSString *)imageURL defaultImage:(UIImage *)defaultImage URL:(NSString *)URL {
    
    TTTableRightImageItem* item = [super itemWithText:text imageURL:imageURL defaultImage:defaultImage URL:URL];    
    
    return item;
}

@end
