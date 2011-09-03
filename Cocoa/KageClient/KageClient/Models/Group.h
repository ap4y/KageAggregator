//
//  Group.h
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subtitle;

@interface Group : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Subtitle *subtitle;

@end
