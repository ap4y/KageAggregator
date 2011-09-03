//
//  KageTableViewController.h
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KageTableDataSource.h"

@interface KageTableViewController : TTTableViewController <UITextFieldDelegate, KageTableSourceDelegate> {
    
    KageTableDataSource* _animeDataSource;
    UITextField* _field;
}

@end
