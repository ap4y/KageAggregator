//
//  Subtitle.h
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Anime;

@interface Subtitle : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * srtId;
@property (nonatomic, retain) NSNumber * seriesCount;
@property (nonatomic, retain) Anime *anime;

@end
