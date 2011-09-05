//
//  KageTableViewController.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageTableViewController.h"

@implementation KageTableViewController

- (void)loadView {
    [super loadView];
}

- (void)createModel {  
    _animeDataSource = [KageTableDataSource dataSourceWithAnime];
    _animeDataSource.delegate = self;
    self.dataSource = _animeDataSource;
}

- (void)dataDidChanged:(KageTableDataSource *)dataSource {
    [self.tableView reloadData];
    [self reloadIfNeeded];
}

- (void)addBtnTouched:(id)sender {
    [_field resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideMenu:YES];
    if (textField.text.length > 0) {
        NSNumberFormatter* numFormat = [[[NSNumberFormatter alloc] init] autorelease];   
        [_animeDataSource performSelectorInBackground:@selector(addAnime:) withObject:[numFormat numberFromString:textField.text]];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    if (_animeDataSource)
        [_animeDataSource updateNewLabels];

    //[self.navigationController setNavigationBarHidden:YES]; 
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES]; 
    self.title = @"Kage-san";
    self.variableHeightRows = YES;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAnime:)] autorelease];
}

- (void)addAnime:(id)sender {    
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:self.tableView.contentOffset];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    TTTableViewCell* cell = (TTTableViewCell*) [self.tableView cellForRowAtIndexPath:indexPath];    
    UIView* menuView = [[[UIView alloc] initWithFrame:cell.contentView.frame] autorelease];    
    
    _field = [[[UITextField alloc] initWithFrame:CGRectMake(10, 10, 250, 40)] autorelease];
    _field.placeholder = @"http://fansubs.ru/base.php?id=....";        
    _field.keyboardType = UIKeyboardTypeNumberPad;   
    _field.delegate = self;    
    
    UIButton* btnAdd = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    btnAdd.frame = CGRectMake(270, 0, 40, 40);
    [btnAdd addTarget:self action:@selector(addBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                  
    [menuView addSubview:_field];            
    [menuView addSubview:btnAdd];
        
    [self showMenu:menuView forCell:cell animated:YES];        
    [_field becomeFirstResponder];
}

- (id<TTTableViewDelegate>) createDelegate {
    TTTableViewDragRefreshDelegate *delegate = [[TTTableViewDragRefreshDelegate alloc] initWithController:self];
    
    return [delegate autorelease];
}

@end
