//
//  TableViewCell.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/27/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "TableViewCellDelegate.h"
#import "StrikethroughLabel.h"

// A custom table cell that renders Task items.
@interface TableViewCell : UITableViewCell <UITextFieldDelegate>

// The item that this cell renders.
@property (nonatomic) Task *taskItem;

// The object that acts as delegate for this cell.
@property (nonatomic, assign) id<TableViewCellDelegate> delegate;

// the label used to render the to-do text
@property (nonatomic, strong, readonly) StrikethroughLabel* label;

@end