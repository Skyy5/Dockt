//
//  Task.h
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/26/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject


// Text for this task
@property (nonatomic, copy) NSString *text;

// A Boolean value that determines the completed state of this item.
@property (nonatomic) BOOL completed;




// Returns a Task item initialized with the given text.
-(id)initWithText:(NSString*)text;

// Helps to return a Task item initialized with the given text.
+(id)taskWithText:(NSString*)text;


@end
