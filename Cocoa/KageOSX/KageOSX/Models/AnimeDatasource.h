//
//  AnimeDatasource.h
//  KageOSX
//
//  Created by Arthur Evstifeev on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Anime.h"

@protocol AnimeDatasourceDelegate;

@interface AnimeDatasource : NSObject {
    NSMutableArray* _items;
    BOOL _loading;
    NSMutableDictionary* _loadedFlags;
    
    id<AnimeDatasourceDelegate> _delegate;
}

@property(nonatomic, retain) id<AnimeDatasourceDelegate> delegate;
@property(nonatomic, retain) NSMutableArray* items;

- (void)removeAnime:(Anime*)anime;
- (void)addAnime:(NSNumber*)objId;
- (void)loadItems;
@end

@protocol AnimeDatasourceDelegate <NSObject>

@optional
- (void)datasourceDidChanged:(AnimeDatasource*)dataSource;

@end