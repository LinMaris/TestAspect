//
//  MightyCrash.m
//  TestHotFix
//
//  Created by 林川 on 2018/4/10.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "MightyCrash.h"

@interface MightyCrash()

@end

@implementation MightyCrash

// 传入 0 就会报错
-(float)divideUsingDenominator:(NSInteger)denominator
{
    return 1.f / denominator;
}

-(void)talk
{
    NSLog(@"说说");
}

-(void)speak:(NSString *)language
{
    NSLog(@"读英语");
}

-(NSString *)eat:(NSString *)food1 food2:(NSString *)food2
{
    return [NSString stringWithFormat:@"我吃了%@, %@",food1, food2];
}

@end
