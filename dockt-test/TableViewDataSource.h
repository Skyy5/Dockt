//
//  TableViewDataSource.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/29/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <Foundation/Foundation.h>

// The TableViewDataSource is adopted by a class that is a source of data
// for a TableView
@protocol TableViewDataSource <NSObject>

// Indicates the number of rows in the table
-(NSInteger)numberOfRows;

// Obtains the cell for the given row
-(UIView *)cellForRow:(NSInteger)row;

// Informs the datasource that a new item has been added at the top of the table
-(void)taskAdded;

@end
