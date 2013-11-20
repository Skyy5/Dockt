//
//  TableView.m
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/29/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import "TableView.h"
#import "TableViewCell.h"

@implementation TableView {
    // the scroll view that hosts the cells
    UIScrollView* _scrollView;
    
    // a set of cells that are reuseable
    NSMutableSet* _reuseCells;
    
    // the Class which indicates the cell type
    Class _cellClass;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectNull];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
         _reuseCells = [[NSMutableSet alloc] init];
        
        /////////////////////////////////////////
        //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.height, 627);
        //self.scrollView.frame = self.view.frame;
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints= NO;
    }
    return self;
}

-(void)layoutSubviews {
    _scrollView.frame = self.frame;
    [self refreshView];
}

//reusing cells methods
-(void)registerClassForCells:(Class)cellClass {
    _cellClass = cellClass;
}

#pragma mark - UIScrollViewDelegate handlers
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshView];
    // forward the delegate method
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

-(UIView*)dequeueReusableCell {
    // first obtain a cell from the reuse pool
    UIView* cell = [_reuseCells anyObject];
    if (cell) {
        NSLog(@"Returning a cell from the pool");
        [_reuseCells removeObject:cell];
    }
    // otherwise create a new cell
    if (!cell) {
        NSLog(@"Creating a new cell");
        cell = [[_cellClass alloc] init];
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate forwarding
-(BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}


-(id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

// based on the current scroll location, recycles off-screen cells and
// creates new ones to fill the empty space.
-(void) refreshView {
    if (CGRectIsNull(_scrollView.frame)) {
        return;
    }
    
    //set the scrollview height (with default width)
    int totalHeightUsed = [_dataSource numberOfRows] * SHC_ROW_HEIGHT;
   
    if ((totalHeightUsed + 100) > 600) {
        NSLog(@"was more than 600, adjusting..\n");
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width,
                                             [_dataSource numberOfRows] * SHC_ROW_HEIGHT);
    }
    else {
        NSLog(@"was less than 600, keep the same\n\nTotal Height used is %d\n", totalHeightUsed);

        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, 600);

    }
    
//################## BRETTS COMMENT ####################
// The below code will fix the scrolling when all of the cells fit on the screen
// it resizes the scrollView content size dynamically based on the cell count.
// Unfortunately, it creates another unknown bug when you add an item
// THIS IS THE MAIN ISSUE AT THE MOMENT
//######################################################
   
    //_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width,
    //                                     [_dataSource numberOfRows] * SHC_ROW_HEIGHT);
    
    //_scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width,600);
    // [self.scrollView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    
    // remove cells that are no longer visible
    for (UIView* cell in [self cellSubviews]) {
        // is the cell off the top of the scrollview?
        if (cell.frame.origin.y + cell.frame.size.height < _scrollView.contentOffset.y) {
            [self recycleCell:cell];
        }
        // is the cell off the bottom of the scrollview?
        if (cell.frame.origin.y > _scrollView.contentOffset.y + _scrollView.frame.size.height) {
            [self recycleCell:cell];
        }
    }
    
    // ensure you have a cell for each row
    int firstVisibleIndex = MAX(0, floor(_scrollView.contentOffset.y / SHC_ROW_HEIGHT));
    int lastVisibleIndex = MIN([_dataSource numberOfRows],
                               firstVisibleIndex + 1 + ceil(_scrollView.frame.size.height / SHC_ROW_HEIGHT));
    for (int row = firstVisibleIndex; row < lastVisibleIndex; row++) {
        UIView* cell = [self cellForRow:row];
        if (!cell) {
            // create a new cell and add to the scrollview
            UIView* cell = [_dataSource cellForRow:row];
            float topEdgeForRow = row * SHC_ROW_HEIGHT;
            cell.frame = CGRectMake(0, topEdgeForRow, _scrollView.frame.size.width, SHC_ROW_HEIGHT);
            [_scrollView insertSubview:cell atIndex:0];
        }
    }
}

-(UIScrollView *)scrollView {
    return _scrollView;
}

// recycles a cell by adding it the set of reuse cells and removing it from the view
-(void) recycleCell:(UIView*)cell {
    [_reuseCells addObject:cell];
    [cell removeFromSuperview];
}

// returns the cell for the given row, or nil if it doesn't exist
-(UIView*) cellForRow:(NSInteger)row {
    float topEdgeForRow = row * SHC_ROW_HEIGHT;
    for (UIView* cell in [self cellSubviews]) {
        if (cell.frame.origin.y == topEdgeForRow) {
            return cell;
        }
    }
    return nil;
}

// the scrollView subviews that are cells
-(NSArray*)cellSubviews {
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for (UIView* subView in _scrollView.subviews) {
        if ([subView isKindOfClass:[TableViewCell class]]) {
            [cells addObject:subView];
        }
    }
    return cells;
}

#pragma mark - property setters
-(void)setDataSource:(id<TableViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self refreshView];
}

//visible cells
-(NSArray*) visibleCells {
    NSMutableArray* cells = [[NSMutableArray alloc] init];
    for (UIView* subView in [self cellSubviews]) {
        [cells addObject:subView];
    }
    NSArray* sortedCells = [cells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView* view1 = (UIView*)obj1;
        UIView* view2 = (UIView*)obj2;
        float result = view2.frame.origin.y - view1.frame.origin.y;
        if (result > 0.0) {
            return NSOrderedAscending;
        } else if (result < 0.0){
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return sortedCells;
}

//reload data mechanism for table
-(void)reloadData {
    // remove all subviews
    [[self cellSubviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self refreshView];
}

@end
