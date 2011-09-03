//
//  KageTableDataSource.m
//  KageClient
//
//  Created by Arthur Evstifeev on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageTableDataSource.h"
#import "CommonData.h"
#import "Anime.h"
#import "TableAnimeItem.h"

@implementation KageTableDataSource
@synthesize delegate = _delegate;

- (void)fillItems {
    NSArray* allAnime = [CommonData allAnime];
    
    NSMutableArray* datasourceItems = [[[NSMutableArray alloc] init] autorelease];
    [datasourceItems addObject:[TTTableTextItem itemWithText:@"Add new anime"]];
    
    for (Anime* anime in allAnime) {
        TableAnimeItem* item = [TableAnimeItem itemWithText:anime.name imageURL:nil defaultImage:[UIImage imageWithData:anime.image] URL:nil];
        item.anime = anime;
        
        [datasourceItems addObject:item];
    }
        
    self.items = datasourceItems;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIView* cell = [self.items objectAtIndex:indexPath.row]; 
        if ([cell isKindOfClass:[TableAnimeItem class]]) {
            TableAnimeItem* item = (TableAnimeItem*)cell;
            
            if ([CommonData removeAnime: item.anime]) {
                [self.items removeObject:item];
                [_delegate dataDidChanged:self];
            }                        
        }                      
    }    
}

- (void)addAnime:(NSNumber*)objId {
    if ([CommonData addAnime:objId]) {
        [self fillItems];
        [_delegate dataDidChanged:self];
    }        
}

+ (id<TTTableViewDataSource>)dataSourceWithAnime {    
    KageTableDataSource* datasource = [[KageTableDataSource alloc] init];
    [datasource fillItems];

    return datasource;
}

@end
