//
//  KageTableDataSource.h
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface KageModel : NSObject <TTModel> {
    NSMutableArray* _delegates;
    NSMutableArray* _animeList;
    BOOL _shouldReload;
    BOOL _loading;
    NSMutableDictionary* _loadedFlags;
}

@property(nonatomic, retain)NSMutableArray* animeList;
@property(nonatomic, readwrite)BOOL shouldReload;

@end

@protocol KageTableSourceDelegate;

@interface KageTableDataSource : TTListDataSource {

    KageModel* _kageModel;
    id<KageTableSourceDelegate> _delegate;    
}

@property(nonatomic, retain) id<KageTableSourceDelegate> delegate;

+ (id<TTTableViewDataSource>)dataSourceWithAnime;

- (void)addAnime:(NSNumber*)objId;
- (void)updateNewLabels;

@end

@protocol KageTableSourceDelegate <NSObject>

- (void)dataDidChanged:(KageTableDataSource*)dataSource;

@end
