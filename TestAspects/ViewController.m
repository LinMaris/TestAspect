//
//  ViewController.m
//  TestAspects
//
//  Created by 林川 on 2018/4/10.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "ViewController.h"
#import <Aspects.h>
#import "MightyCrash.h"

#import <GHConsole.h>

#import "TestAspectToolVC.h"
#import "Person.h"

@interface ViewController ()

@property(nonatomic,strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 测试热更新, 注入代码在AppDelegate中, 实际上注入代码从服务器获取,在合适的时候执行
    [self testHotFix];
    
    // 测试Aspect基本功能
//    [self testAspectTool];
}

-(void)testAspectTool
{
    TestAspectToolVC *testVC = [TestAspectToolVC new];
    [self addChildViewController:testVC];
    testVC.view.alpha = 0;  // testVC 中的viewDidLoad会被调用
    
    self.person = [Person new];
    
    // 流程: 程序运行, 通过Aspect hook speak/eat 方法, 当speak/eat被调用时, 在Aspect中的block中对应操作
}

-(void)testHotFix
{
    /**
     GHConsole 可以显示console的打印信息
     地址: https://github.com/Liaoworking/GHConsole
     
     由于divideUsingDenominator已经被hook了, 当分母为0时,该方法被跳过,  故没有返回Inf 错误
     */
    MightyCrash *mc = [MightyCrash new];
    float result = [mc divideUsingDenominator:3];
    GGLog(@"result3: %f", result);
    result = [mc divideUsingDenominator:0];
    GGLog(@"won't crash");
}

- (IBAction)clickMe:(id)sender {
    
    [self.person speak:@"jack"];
    
    [self.person eat:@"苹果" food2:@"梨子"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
