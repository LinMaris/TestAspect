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

@end
