//
//  KageTableDataSource.h
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@protocol KageTableSourceDelegate;

@interface KageTableDataSource : TTListDataSource {

    id<KageTableSourceDelegate> _delegate;    
}

@property(nonatomic, retain) id<KageTableSourceDelegate> delegate;

+ (id<TTTableViewDataSource>)dataSourceWithAnime;

- (void)addAnime:(NSNumber*)objId;

@end

@protocol KageTableSourceDelegate <NSObject>

- (void)dataDidChanged:(KageTableDataSource*)dataSource;

@end
