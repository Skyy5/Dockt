//
//  ViewController.m
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/26/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import "ViewController.h"
#import "Task.h"
#import "TableViewCell.h"
//#import "TableView.h"

@interface ViewController (){
    NSMutableArray * _taskItem;
    // the offset applied to cells when entering “edit mode”
    float _editingOffset;
    
    TableViewDragAddNew* _dragAddNew;
}

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor blackColor];
   /*
    float sizeOfContent = 0;
    UIView *lLast = [scrollView.subviews lastObject];
    NSInteger wd = lLast.frame.origin.y;
    NSInteger ht = lLast.frame.size.height;
    
    sizeOfContent = wd+ht;
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, sizeOfContent);
    */
    
    /*
    [super viewDidLoad];
    //connect datasource to tableView
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //styling crap
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
    
    
    //specify that the UITableViewCell will provide the cells for tableview
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"cell"];

     */
    
    //populate this array with dummy tasks, the power of the taskWithText method is shown
    // here, don't need to alloc/init each new task object
    _taskItem = [[NSMutableArray alloc] init];
    [_taskItem addObject:[Task taskWithText:@"Buy plutonium"]];
    [_taskItem addObject:[Task taskWithText:@"Pack bags for Blizzcon!"]];
    [_taskItem addObject:[Task taskWithText:@"Catch em' all!"]];
    [_taskItem addObject:[Task taskWithText:@"Find out who let the dogs out"]];
    [_taskItem addObject:[Task taskWithText:@"Buy a new iPhone"]];
    [_taskItem addObject:[Task taskWithText:@"Find missing socks"]];
    [_taskItem addObject:[Task taskWithText:@"Read chapters"]];
    [_taskItem addObject:[Task taskWithText:@"Master Objective-C"]];
    [_taskItem addObject:[Task taskWithText:@"Fix GF's website"]];
    [_taskItem addObject:[Task taskWithText:@"Drink less beer"]];
    [_taskItem addObject:[Task taskWithText:@"Learn to draw"]];
    [_taskItem addObject:[Task taskWithText:@"Wash car"]];
    [_taskItem addObject:[Task taskWithText:@"Sell things on eBay"]];
    [_taskItem addObject:[Task taskWithText:@"Learn to juggle"]];
    [_taskItem addObject:[Task taskWithText:@"Be leet"]];
    
    //specify the custom cell type to reuse
    [self.tableView registerClassForCells:[TableViewCell class]];
    _dragAddNew = [[TableViewDragAddNew alloc] initWithTableView:self.tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//textfield scroll methods
-(void)cellDidBeginEditing:(TableViewCell *)editingCell {
    _editingOffset = _tableView.scrollView.contentOffset.y - editingCell.frame.origin.y;
    for(TableViewCell* cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.frame = CGRectOffset(cell.frame, 0, _editingOffset);
                             if (cell != editingCell) {
                                 cell.alpha = 0.3;
                             }
                         }];
    }
}

-(void)cellDidEndEditing:(TableViewCell *)editingCell {
    for(TableViewCell* cell in [_tableView visibleCells]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             cell.frame = CGRectOffset(cell.frame, 0, -_editingOffset);
                             if (cell != editingCell)
                             {
                                 cell.alpha = 1.0;
                             }
                         }];
    }
}

#pragma mark - TableViewDataSource methods
-(NSInteger)numberOfRows {
    return _taskItem.count;
}

-(UITableViewCell *)cellForRow:(NSInteger)row {
    TableViewCell* cell = (TableViewCell*)[self.tableView dequeueReusableCell];
    Task *item = _taskItem[row];
    cell.taskItem = item;
    cell.delegate = self;
    cell.backgroundColor = [self colorForIndex:row];
    return cell;
}

//increase the height of each row and set the background color per row
-(UIColor*)colorForIndex:(NSInteger) index {
    //NSUInteger itemCount = _taskItem.count - 1;
    //float val = ((float)index / (float)itemCount) * 0.2;
    //return [UIColor colorWithRed:0.3 + val green:0.0 blue:0.3 + val alpha:1.0];
    return [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];

}

#pragma mark - UITableViewDataDelegate protocol methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [self colorForIndex:indexPath.row];
    
}

//delete task when necessary
-(void)taskDeleted:(id)taskItem {
    float delay = 0.0;
    
    // remove the model object
    [_taskItem removeObject:taskItem];
    
    // find the visible cells
    NSArray* visibleCells = [self.tableView visibleCells];
    
    UIView* lastView = [visibleCells lastObject];
    bool startAnimating = false;
    
    // iterate over all of the cells
    for(TableViewCell* cell in visibleCells) {
        if (startAnimating) {
            [UIView animateWithDuration:0.3
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 if (cell == lastView) {
                                     [self.tableView reloadData];
                                 }
                             }];
            delay+=0.03;
        }
        
        // if you have reached the item that was deleted, start animating
        if (cell.taskItem == taskItem) {
            startAnimating = true;
            cell.hidden = YES;
        }
    }
    //NSLog(_scrollView.contentSize.height);
}

//complete task when necessary
-(void)taskCompleted:(id)taskItem {
    NSLog(@"Task completed!\n");
    // use the UITableView to animate the removal of this row
    /*
    NSUInteger index = [_taskItem indexOfObject:taskItem];
    [self.tableView beginUpdates];
    [_taskItem removeObject:taskItem];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
     */
}


//adds a new task to the array
-(void)taskAdded {
    // create the new item
    Task* taskItem = [[Task alloc] init];
    [_taskItem insertObject:taskItem atIndex:0];
    // refresh the table
    [_tableView reloadData];
    // enter edit mode
    TableViewCell* editCell;
    for (TableViewCell* cell in _tableView.visibleCells) {
        if (cell.taskItem == taskItem) {
            editCell = cell;
            break;
        }
    }
    [editCell.label becomeFirstResponder];
}




@end
