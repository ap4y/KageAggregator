//
//  Anime.h
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subtitle;

@interface Anime : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * baseId;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *subtitles;
@end

@interface Anime (CoreDataGeneratedAccessors)

- (void)addSubtitlesObject:(Subtitle *)value;
- (void)removeSubtitlesObject:(Subtitle *)value;
- (void)addSubtitles:(NSSet *)values;
- (void)removeSubtitles:(NSSet *)values;

- (Subtitle*)subtitleWithSrtId:(NSNumber*)srtId;

@end
