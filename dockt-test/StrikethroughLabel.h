//
//  StrikethroughLabel.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/28/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <UIKit/UIKit.h>

// A UILabel subclass that can optionally have a strikethrough.
@interface StrikethroughLabel : UITextField
// A Boolean value that determines whether the label should have a strikethrough.
@property (nonatomic) bool strikethrough;

@end
