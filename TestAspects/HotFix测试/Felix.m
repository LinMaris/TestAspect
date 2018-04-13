//
//  Felix.m
//  TestAspects
//
//  Created by 林川 on 2018/4/10.
//  Copyright © 2018年 LinMaris. All rights reserved.
//

#import "Felix.h"
#import <Aspects.h>
#import <objc/runtime.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface Felix()

@end


@implementation Felix

/** 创建单例 */
+(instancetype)sharedInstance
{
    static Felix *sharedInatance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInatance = [[self alloc] init];
    });
    return sharedInatance;
}

/** 执行脚本 */
+ (void)evalString:(NSString *)javascriptString
{
    [[self context] evaluateScript:javascriptString];
}

/** JS环境 */
+ (JSContext *)context
{
    static JSContext *_context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _context = [[JSContext alloc] init];
        [_context setExceptionHandler:^(JSContext *context, JSValue *value) {
            NSLog(@"Oops: %@", value);
        }];
    });
    return _context;
}

/** 操作方法 */
+ (void)fixIt
{
    /// Hook 实例方法
    [self aspectInstanceMethod];
    
    /// Hook 类方法
    [self aspectClassMethod];
    
    /// perform 类方法 有返回值
    [self performSelectorClassMethodWithReturnValue];
    
    /// perform 类方法 无返回值
    [self performSelectorClassMethodWithNOReturnValue];
    
    /// perform 实例方法 有返回值
    [self performSelectorInstanceMethodWithReturnValue];
    
    /// perform 实例方法 无返回值
    [self performSelectorInstanceMethodWithNOReturnValue];
    
    [self context][@"runInvocation"] = ^(NSInvocation *invocation) {
        [invocation invoke];
    };
    
    // helper
    [[self context] evaluateScript:@"var console = {}"];
    [self context][@"console"][@"log"] = ^(id message) {
        NSLog(@"Javascript log: %@",message);
    };
}

#pragma mark - Other
+ (void)_fixWithMethod:(BOOL)isClassMethod
      aspectionOptions:(AspectOptions)option
          instanceName:(NSString *)instanceName
          selectorName:(NSString *)selectorName
               fixImpl:(JSValue *)fixImpl
{
    Class klass = NSClassFromString(instanceName);
    if (isClassMethod) {
        klass = object_getClass(klass);
    }
    SEL sel = NSSelectorFromString(selectorName);
    
    [klass aspect_hookSelector:sel withOptions:option usingBlock:^(id<AspectInfo> aspectInfo){
        [fixImpl callWithArguments:@[aspectInfo.instance, aspectInfo.originalInvocation, aspectInfo.arguments]];
    } error:nil];
}

+ (id)_runClassWithClassName:(NSString *)className
                    selector:(NSString *)selector
                        obj1:(id)obj1
                        obj2:(id)obj2
{
    Class klass = NSClassFromString(className);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [klass performSelector:NSSelectorFromString(selector) withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}

+ (id)_runInstanceWithInstance:(id)instance
                      selector:(NSString *)selector
                          obj1:(id)obj1
                          obj2:(id)obj2
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [instance performSelector:NSSelectorFromString(selector) withObject:obj1 withObject:obj2];
#pragma clang diagnostic pop
}

+ (void)aspectInstanceMethod
{
    /**
     hook实例方法 执行前出发
     */
    [self context][@"fixInstanceMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    /**
     hook实例方法 执行时出发
     */
    [self context][@"fixInstanceMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    /**
     hook实例方法 执行后出发
     */
    [self context][@"fixInstanceMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:NO aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
}

+ (void)aspectClassMethod
{
    /**
     hook类方法 执行前触发
     */
    [self context][@"fixClassMethodBefore"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionBefore instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    /**
     hook类方法 执行时触发
     */
    [self context][@"fixClassMethodReplace"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionInstead instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
    /**
     hook类方法 执行后触发
     */
    [self context][@"fixClassMethodAfter"] = ^(NSString *instanceName, NSString *selectorName, JSValue *fixImpl) {
        [self _fixWithMethod:YES aspectionOptions:AspectPositionAfter instanceName:instanceName selectorName:selectorName fixImpl:fixImpl];
    };
    
}

+ (void)performSelectorClassMethodWithReturnValue
{
    /**
     performSelector 类方法 无参数 返回值
     */
    [self context][@"runClassWithNoParamter"] = ^id(NSString *className, NSString *selectorName) {
        return [self _runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    
    /**
     performSelector 类方法 一参数 返回值
     */
    [self context][@"runClassWith1Paramter"] = ^id(NSString *className, NSString *selectorName, id obj1) {
        return [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    
    /**
     performSelector 类方法 两参数 返回值
     */
    [self context][@"runClassWith2Paramters"] = ^id(NSString *className, NSString *selectorName, id obj1, id obj2) {
        return [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
}

+ (void)performSelectorClassMethodWithNOReturnValue
{
    /**
     performSelector 类方法 无参数 无返回值
     */
    [self context][@"runVoidClassWithNoParamter"] = ^(NSString *className, NSString *selectorName) {
        [self _runClassWithClassName:className selector:selectorName obj1:nil obj2:nil];
    };
    
    /**
     performSelector 类方法 一参数 无返回值
     */
    [self context][@"runVoidClassWith1Paramter"] = ^(NSString *className, NSString *selectorName, id obj1) {
        [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:nil];
    };
    
    /**
     performSelector 类方法 两参数 无返回值
     */
    [self context][@"runVoidClassWith2Paramters"] = ^(NSString *className, NSString *selectorName, id obj1, id obj2) {
        [self _runClassWithClassName:className selector:selectorName obj1:obj1 obj2:obj2];
    };
}

+ (void)performSelectorInstanceMethodWithReturnValue
{
    /**
     performSelector 实例方法 无参数 有返回值
     */
    [self context][@"runInstanceWithNoParamter"] = ^id(id instance, NSString *selectorName) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    
    /**
     performSelector 实例方法 一参数 有返回值
     */
    [self context][@"runInstanceWith1Paramter"] = ^id(id instance, NSString *selectorName, id obj1) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    
    /**
     performSelector 实例方法 两参数 有返回值
     */
    [self context][@"runInstanceWith2Paramters"] = ^id(id instance, NSString *selectorName, id obj1, id obj2) {
        return [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
}

+ (void)performSelectorInstanceMethodWithNOReturnValue
{
    /**
     performSelector 实例方法 无参数 无返回值
     */
    [self context][@"runVoidInstanceWithNoParamter"] = ^(id instance, NSString *selectorName) {
        NSLog(@"selectorName: %@", selectorName);
        [self _runInstanceWithInstance:instance selector:selectorName obj1:nil obj2:nil];
    };
    
    /**
     performSelector 实例方法 一参数 无返回值
     */
    [self context][@"runVoidInstanceWith1Paramter"] = ^(id instance, NSString *selectorName, id obj1) {
        [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:nil];
    };
    
    /**
     performSelector 实例方法 两参数 无返回值
     */
    [self context][@"runVoidInstanceWith2Paramters"] = ^(id instance, NSString *selectorName, id obj1, id obj2) {
        [self _runInstanceWithInstance:instance selector:selectorName obj1:obj1 obj2:obj2];
    };
}



@end
