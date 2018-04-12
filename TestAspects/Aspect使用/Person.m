//
//  Person.m
//  TestAspects
//
//  Created by 林川 on 2018/4/13.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)speak:(NSString *)string{
    NSLog(@"说：%@",string);
}

-(void)eat:(NSString *)food1 food2:(NSString *)food2
{
    NSLog(@"food1: %@, food2: %@",food1, food2);
}

@end
