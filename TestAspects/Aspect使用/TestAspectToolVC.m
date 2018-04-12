//
//  TestAspectToolVC.m
//  TestAspects
//
//  Created by 林川 on 2018/4/13.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "TestAspectToolVC.h"
#import "Person.h"
#import <Aspects.h>

@interface TestAspectToolVC ()

@end

@implementation TestAspectToolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     
     这里用的Aspect是cocopod上面的第三方库, 我导入的Aspect_注释版 没有参与编译,所以不会报错
     注释版地址: https://git.coding.net/Dely/JYAOPDemo.git
     
     */
//    [self testAspectBefore];
    
//    [self testAspectAfter];
    
    [self testAspectInstead];
}

-(void)testAspectBefore
{
    [Person aspect_hookSelector:@selector(eat:food2:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo>aspectInfo,NSString *food1, NSString *food2){
        NSLog(@"arguments1 = %@, %@, %@",aspectInfo.arguments, food1, food2);
    } error:nil];
}

-(void)testAspectInstead
{
    //speak方法被执行的时候, 由于被hook了
    [Person aspect_hookSelector:@selector(speak:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo>aspectInfo){
        
        NSInvocation *invoke = aspectInfo.originalInvocation;
        // 当传入的参数是 jack 时, 替换掉jack为lili
        if([aspectInfo.arguments[0] isEqualToString:@"jack"]){ // 替换参数
            
            NSString *arg = @"lili";
            [invoke setArgument:&arg atIndex:2]; // 0: target, 1: action, 234...:参数
            [invoke invoke];
        }
        else {   // 替换方法 将speak替换为eat方法, 并传入对应参数
            [aspectInfo.instance eat:@"米饭" food2:@"面条"];
        }
        
    } error:nil];
}

-(void)testAspectAfter
{
    [Person aspect_hookSelector:@selector(speak:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo, NSString *name){
        NSLog(@"arguments2 = %@",aspectInfo.arguments);
    } error:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
