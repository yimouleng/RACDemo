//
//  ViewController.m
//  RACDemo
//
//  Created by Eli on 15/12/21.
//  Copyright © 2015年 Ely. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "LxDBAnything.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*******************************第一部分----简单使用*******************************/
    //文本框事件：
    [self textFiledTest];
    //手势
//    [self gestureTest];
    //通知
//    [self notificationTest];
    //定时器NSTime
//    [self timeTest];
    //代理 (有局限，只能取代没有返回值的代理方法)
//    [self delegateTest];
    //KVO
//    [self kvoTest];
    /*******************************第二部分----进阶*******************************/
    //信号 （创建信号 & 激活信号 & 废弃信号）
//    [self createSignal];
    //信号的处理
    //map (映射)和filter
//    [self mapAndFilter];
    //delay延迟
//    [self delay];
    //最先开始的时候
//    [self startWith];
    //超时
//    [self timeOut];
    //take skip
//    [self takeOrSkip];
    //throttle(截流)  结合即时搜索优化来讲
//    [self throttle];
    //repeat 重复
//    [self repeatTest];
    //merge 合并信号
//    [self mergeTest];
    //RAC(TARGET, ...) 宏
//    [self RAC];
    //rac做一个秒表
//    [self stopwatch];
    
    
}
#pragma mark stopwatch
- (void)stopwatch
{
    UILabel * label = ({
       
        UILabel * label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor cyanColor];
        label;
    });
    [self.view addSubview:label];
    
    @weakify(self);
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.size.mas_equalTo(CGSizeMake(240, 40));
        make.center.equalTo(self.view);
        
    }];
    
    RAC(label, text) = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] map:^NSString *(NSDate * date) {
        
        return date.description;
    }];
}
#pragma mark Rac
- (void)RAC
{
    //button setBackgroundColor:forState:
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    
    @weakify(self);
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    
    RAC(button, backgroundColor) = [RACObserve(button, selected) map:^UIColor *(NSNumber * selected) {
        
        return [selected boolValue] ? [UIColor redColor] : [UIColor greenColor];
    }];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(UIButton * btn) {
        
        btn.selected = !btn.selected;
    }];

}
#pragma mark mergeTest
- (void)mergeTest
{
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LxPrintAnything(a);
            [subscriber sendNext:@"a"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LxPrintAnything(b);
            [subscriber sendNext:@"b"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
    //merge 合并  concat 链接  zipWith
    [[RACSignal concat:@[signalA, signalB]]subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];
    
//    [[signalA combineLatestWith:signalB]subscribeNext:^(id x) {
//        
//        LxDBAnyVar(x);
//    }];
    
//    [[RACSignal combineLatest:@[signalA, signalB]]subscribeNext:^(id x) {
//        
//        LxDBAnyVar(x);
//    }];
}
#pragma  mark repeat
- (void)repeatTest
{
    //repeat:
    [[[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        
        return nil;
    }]delay:1]repeat]take:3] subscribeNext:^(id x) {
	       
        LxDBAnyVar(x);
    } completed:^{
        
        LxPrintAnything(completed);
    }];

}
#pragma mark  throttle
- (void)throttle
{
    UITextField * textField = [[UITextField alloc]init];
    textField.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:textField];
    
    @weakify(self);
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    //throttle 后面是个时间 表示rac_textSignal发送消息，0.3秒内没有再次发送就会相应，若是0.3内又发送消息了，便会在新的信息处重新计时
    //distinctUntilChanged 表示两个消息相同的时候，只会发送一个请求
    //ignore 表示如果消息和ignore后面的消息相同，则会忽略掉这条消息，不让其发送
    [[[[[[textField.rac_textSignal throttle:0.3] distinctUntilChanged] ignore:@""] map:^id(id value) {
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            //  network request
            [subscriber sendNext:value];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                
                //  cancel request
            }];
        }];
    }]switchToLatest] subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];

    
}
#pragma mark takeOrSkip
- (void)takeOrSkip
{
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"rac1"];
        [subscriber sendNext:@"rac2"];
        [subscriber sendNext:@"rac3"];
        [subscriber sendNext:@"rac4"];
        [subscriber sendCompleted];
        return nil;
    }]take:2];//Skip takeLast  takeUntil   takeWhileBlock:   skipWhileBlock:  skipUntilBlock:


    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];
}
#pragma mark timeOut
- (void)timeOut
{
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[RACScheduler mainThreadScheduler]afterDelay:3 schedule:^{
            
            [subscriber sendNext:@"rac"];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }] timeout:2 onScheduler:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         
         LxDBAnyVar(x);
     } error:^(NSError *error) {
         
         LxDBAnyVar(error);
     } completed:^{
         
         LxPrintAnything(completed);
     }];

}
#pragma mark startWith
- (void)startWith
{
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
//        [subscriber sendNext:@"123"];//startWith:@"123"等同于这句话 也就是第一个发送，主要是位置
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        return nil;
    }]startWith:@"123"];
    LxPrintAnything(start);
    //创建订阅者
    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];

}
#pragma mark delay
- (void)delay
{
    //创建信号
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"rac"];
        [subscriber sendCompleted];
        return nil;
    }]delay:2];
    LxPrintAnything(start);
    //创建订阅者
    [signal subscribeNext:^(id x) {
        LxDBAnyVar(x);
    }];
    
}
#pragma mark map (映射)和filter
- (void)mapAndFilter
{
    UITextField * textField = ({
        UITextField * textField = [[UITextField alloc]init];
        textField.backgroundColor = [UIColor cyanColor];
        
        textField;
    });
    [self.view addSubview:textField];
    
    @weakify(self); //  __weak __typeof__(self) self_weak_ = self;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);    // __strong __typeof__(self) self = self_weak_;
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];

    [[[textField.rac_textSignal map:^id(NSString *text) {
        
       LxDBAnyVar(text);
        
        return @(text.length);
        
    }]filter:^BOOL(NSNumber *value) {
        
        return value.integerValue > 3;
        
    }] subscribeNext:^(id x) {
         LxDBAnyVar(x);
    }];

}
#pragma mark Signal
- (RACSignal *)createSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        RACDisposable * schedulerDisposable = [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
            
            if (arc4random()%10 > 1) {
                
                [subscriber sendNext:@"Login response"];
                [subscriber sendCompleted];
            }
            else {
                
                [subscriber sendError:[NSError errorWithDomain:@"LOGIN_ERROR_DOMAIN" code:444 userInfo:@{}]];
            }
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [schedulerDisposable dispose];
        }];
    }];
}

#pragma mark KVO
- (void)kvoTest
{
    UIScrollView * scrollView = [[UIScrollView alloc]init];
    scrollView.delegate = (id<UIScrollViewDelegate>)self;
    [self.view addSubview:scrollView];
    
    UIView * scrollViewContentView = [[UIView alloc]init];
    scrollViewContentView.backgroundColor = [UIColor yellowColor];
    [scrollView addSubview:scrollViewContentView];
    
    @weakify(self);
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(80, 80, 80, 80));
    }];
    
    [scrollViewContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.edges.equalTo(scrollView);
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)));
    }];
    
    [RACObserve(scrollView, contentOffset) subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];
    
//  （好处：写法简单，keypath有代码提示）
}
#pragma mark 代理
- (void)delegateTest
{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"RAC" message:@"ReactiveCocoa" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ensure", nil];
    
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple * tuple) {
        
        LxDBAnyVar(tuple);
        
        LxDBAnyVar(tuple.first);
        LxDBAnyVar(tuple.second);
        LxDBAnyVar(tuple.third);
    }];
    [alertView show];
    
    
    //	更简单的方式：
    [[alertView rac_buttonClickedSignal]subscribeNext:^(id x) {
        
        LxDBAnyVar(x);
    }];

}
#pragma mark 定时器
- (void)timeTest
{
    //1. 延迟某个时间后再做某件事
    [[RACScheduler mainThreadScheduler]afterDelay:2 schedule:^{
        
        LxPrintAnything(rac);
    }];
    
    //2. 每间隔多长时间做一件事
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDate * date) {
        
        LxDBAnyVar(date);
    }];

}
#pragma mark 通知
- (void)notificationTest
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(NSNotification * notification) {
        
        LxDBAnyVar(notification);
    }];
    //不需要removeObserver
}
#pragma mark 手势
- (void)gestureTest
{
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [[tap rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer * tap) {
        
        LxDBAnyVar(tap);
    }];
    [self.view addGestureRecognizer:tap];
}
#pragma mark 文本框事件
- (void)textFiledTest{
    
    UITextField * textField = ({
        UITextField * textField = [[UITextField alloc]init];
        textField.backgroundColor = [UIColor cyanColor];
        
        textField;
    });
   [self.view addSubview:textField];
    
    @weakify(self); //  __weak __typeof__(self) self_weak_ = self;
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);    // __strong __typeof__(self) self = self_weak_;
        make.size.mas_equalTo(CGSizeMake(180, 40));
        make.center.equalTo(self.view);
    }];
    
    [[textField rac_signalForControlEvents:UIControlEventEditingChanged]
     subscribeNext:^(id x) {
         
         LxDBAnyVar(x);
     }];
    //更简单的方式
    [textField.rac_textSignal subscribeNext:^(NSString *x) {
        
        LxDBAnyVar(x);
    }];
}
#pragma mark 缩键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
