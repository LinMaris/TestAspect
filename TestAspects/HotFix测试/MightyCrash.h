//
//  MightyCrash.h
//  TestHotFix
//
//  Created by 林川 on 2018/4/10.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MightyCrash : NSObject

- (float)divideUsingDenominator:(NSInteger)denominator;

-(void)talk;

-(void)speak: (NSString *)language;

-(NSString *)eat: (NSString *)food1 food2: (NSString *)food2;

@end
