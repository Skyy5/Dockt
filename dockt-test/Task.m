//
//  Task.m
//  DOCKT-Test
//
//  Created by Brett Hamm on 10/26/2013.
//  Copyright (c) 2013 Team Yeezus. All rights reserved.
//

#import "Task.h"

@implementation Task

//for use with the method below to initialize a task
-(id)initWithText:(NSString*)text {
    //if the same object type needs to be initialized, make sure it's not the old one
    if (self = [super init]) {
        self.text = text;
    }
    return self;
}

//uses above method, elegant way to create tasks
+(id)taskWithText:(NSString *)text {
    return [[Task alloc] initWithText:text];
}

@end
