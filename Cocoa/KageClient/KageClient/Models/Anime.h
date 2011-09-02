//
//  Anime.h
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Anime : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * baseId;
@property (nonatomic, retain) NSSet *subtitles;
@end

@interface Anime (CoreDataGeneratedAccessors)

- (void)addSubtitlesObject:(NSManagedObject *)value;
- (void)removeSubtitlesObject:(NSManagedObject *)value;
- (void)addSubtitles:(NSSet *)values;
- (void)removeSubtitles:(NSSet *)values;

@end
