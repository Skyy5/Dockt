//
//  ViewController.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/26/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewCellDelegate.h"
#import "TableView.h"
#import "TableViewDragAddNew.h"

@interface ViewController : UIViewController <TableViewDataSource, TableViewCellDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TableView *tableView;

@property (nonatomic, assign, readonly) UIScrollView* scrollView;

@end
