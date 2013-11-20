//
//  TableViewCellDelegate.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/28/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@class TableViewCell;

// A protocol that the TableViewCell uses to inform of state change
@protocol TableViewCellDelegate <NSObject>


// indicates that the given item has been deleted
-(void) taskDeleted:(Task*)taskItem;

// indicates that the given item has been completed
-(void) taskCompleted:(Task*)taskItem;

// Indicates that the edit process has begun for the given cell
-(void)cellDidBeginEditing:(TableViewCell*)cell;

// Indicates that the edit process has committed for the given cell
-(void)cellDidEndEditing:(TableViewCell*)cell;

@end