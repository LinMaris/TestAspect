//
//  AppDelegate.m
//  TestAspects
//
//  Created by 林川 on 2018/4/10.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "AppDelegate.h"
#import "Felix.h"

#import <GHConsole.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self hotFix];
    
    [[GHConsole sharedConsole] startPrintLog];
    
    return YES;
}

-(void)hotFix
{
    [Felix fixIt];
    NSString *fixScriptStr = @" \
    fixInstanceMethodReplace('MightyCrash', 'divideUsingDenominator:', function(instance, originInvocation, originArguments){ \
        if (originArguments[0] == 0) { \
        console.log('zero goes here');\
        } else { \
           runInvocation(originInvocation); \
        }}\
    );";
    
    NSString *fixScriptBefore = @" \
    fixInstanceMethodBefore('MightyCrash', 'divideUsingDenominator:', function(instance, originInvocation, originArguments){ \
        if (originArguments[0] == 0) { \
            console.log('我之前知道是0');\
        } else { \
          runInvocation(originInvocation); \
        }}\
    );";
    
    NSString *fixScriptAfter = @" \
    fixInstanceMethodAfter('MightyCrash', 'divideUsingDenominator:', function(instance, originInvocation, originArguments){ \
        if (originArguments[0] == 0) { \
        console.log('我之后知道是0');\
        } else { \
        runInvocation(originInvocation); \
        }}\
    );";
    
    /// Hook 类方法 和 实例方法是类似的
    [Felix evalString:fixScriptBefore];
    [Felix evalString:fixScriptStr];
    [Felix evalString:fixScriptAfter];
    
    NSString *speakScriptStr = @"\
    runInstanceWith2Paramters('MightyCrash', 'eat:', 'banner', 'Apple',  function(value,value2,value3){\
        console.log(value)\
    });";
    
//    [Felix evalString:speakScriptStr];
}

























- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
