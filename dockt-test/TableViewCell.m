//
//  TableViewCell.m
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/27/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TableViewCell.h"
#import "StrikethroughLabel.h"

@implementation TableViewCell
{
    CAGradientLayer* _gradientLayer;
    CGPoint _originalCenter;
	BOOL _deleteOnDragRelease;
    BOOL _completeOnDragRelease;
    //StrikethroughLabel* _label;
    CALayer* _taskCompleteLayer;
    UILabel *_tickLabel;
	UILabel *_crossLabel;
}

const float UI_CUES_MARGIN = 10.0f;
const float UI_CUES_WIDTH = 50.0f;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    //NSLog(@"in cell code\n");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //need this in IOS 7 !!!!!!!!!!!!!
        [self.contentView.superview setClipsToBounds:NO];
        
        // create a label that renders the to-do item text
        _label = [[StrikethroughLabel alloc] initWithFrame:CGRectNull];
        _label.delegate = self;
        _label.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:16];
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        
        // remove the default white highlight for selected cells in iOS 7
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // add a layer that overlays the cell adding a subtle gradient effect
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
                                  (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor],
                                  (id)[[UIColor clearColor] CGColor],
                                  (id)[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
        _gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        
        //################## BRETTS COMMENT ####################
        // Needed to change this to index 1 for iOS7, so the gradient
        // layer appears overtop of the other layers
        //######################################################
        
        [self.layer insertSublayer:_gradientLayer atIndex:1];
        
        // add a layer that renders a green background when an item is complete
        
        /* DOES NOT WORK, LAYER GOING BEHIND MAIN LAYER, OR INFRONT OF ALL
        _taskCompleteLayer = [CALayer layer];
        _taskCompleteLayer.backgroundColor = [[[UIColor alloc] initWithRed:0.0 green:0.6 blue:0.0 alpha:1.0] CGColor];
        _taskCompleteLayer.hidden = YES;
        [self.layer insertSublayer:_taskCompleteLayer atIndex:0];    //!!!!!!!!!!!!!!!!
        */
        
        // add a pan recognizer
        UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
        
        // add a tick and cross
        _tickLabel = [self createCueLabel];
        _tickLabel.text = @"\u2713";
        _tickLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_tickLabel];
        _crossLabel = [self createCueLabel];
        _crossLabel.text = @"\u2717";
        _crossLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_crossLabel];

        
    }
    return self;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // close the keyboard on enter
    [textField resignFirstResponder];
    return NO;
}

//methods for the scrolling when typing
-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate cellDidEndEditing:self];
    self.taskItem.text = textField.text;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate cellDidBeginEditing:self];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // disable editing of completed to-do items
    return !self.taskItem.completed;
}


//for strikethrough
const float LABEL_LEFT_MARGIN = 15.0f;

-(void)layoutSubviews {
    [super layoutSubviews];
    // ensure the gradient layers occupies the full bounds
    _gradientLayer.frame = self.bounds;
    _taskCompleteLayer.frame = self.bounds;
    _label.frame = CGRectMake(LABEL_LEFT_MARGIN, 0,
                              self.bounds.size.width - LABEL_LEFT_MARGIN,self.bounds.size.height);
    
    _tickLabel.frame = CGRectMake(-UI_CUES_WIDTH - UI_CUES_MARGIN, 0,
                                  UI_CUES_WIDTH, self.bounds.size.height);
    _crossLabel.frame = CGRectMake(self.bounds.size.width + UI_CUES_MARGIN, 0,
                                   UI_CUES_WIDTH, self.bounds.size.height);
}

-(void)setTaskItem:(Task *)taskItem {
    _taskItem = taskItem;
    // we must update all the visual state associated with the model item
    _label.text = taskItem.text;
    _label.strikethrough = taskItem.completed;
    _taskCompleteLayer.hidden = !taskItem.completed;
}


// utility method for creating the contextual cues
-(UILabel*) createCueLabel {
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectNull];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:32.0];
    label.backgroundColor = [UIColor clearColor];
    return label;
}


#pragma mark - horizontal pan gesture methods

// states that the handlePan will be used, and the cell class will be the delegate
// disallows viertical panning IMPORTANT!
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    }
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // start of pan (calculate distance to deletion point)
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        _originalCenter = self.center;
    }
    
    // during pan (check distance needed to be considered a delete, update flag if it passed)
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        // determine whether the item has been dragged far enough to initiate a delete / complete
        _deleteOnDragRelease = self.frame.origin.x < -self.frame.size.width / 3;
        _completeOnDragRelease = self.frame.origin.x > self.frame.size.width / 3;
        
        // fade the contextual cues
        float cueAlpha = fabsf(self.frame.origin.x) / (self.frame.size.width / 3);
        _tickLabel.alpha = cueAlpha;
        _crossLabel.alpha = cueAlpha;
        
        // indicate when the item have been pulled far enough to invoke the given action
        _tickLabel.textColor = _completeOnDragRelease ?
        [UIColor greenColor] : [UIColor whiteColor];
        _crossLabel.textColor = _deleteOnDragRelease ?
        [UIColor redColor] : [UIColor whiteColor];
        
    }
    
    // end of pan (see if user wanted to delete, or pulled back to cancel)
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y,
                                          self.bounds.size.width, self.bounds.size.height);
        if (!_deleteOnDragRelease) {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 self.frame = originalFrame;
                             }
             ];
        }
        if (_deleteOnDragRelease) {
            // notify the delegate that this item should be deleted
           [self.delegate taskDeleted:self.taskItem];
        }
        
        if (_completeOnDragRelease) {
            // mark the item as complete and update the UI state
            [self.delegate taskCompleted:self.taskItem];

            self.taskItem.completed = YES;
            _taskCompleteLayer.hidden = NO;

            _label.strikethrough = YES;
        }
    }
    
}



@end