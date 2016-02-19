//
//  ViewController.m
//  YTDataSelectDemo
//
//  Created by TonyAng on 16/2/15.
//  Copyright © 2016年 TonyAng. All rights reserved.
//

#import "ViewController.h"
#import "YTDatePick.h"
@interface ViewController ()

@property (nonatomic, copy) UIButton *btn;
@property (nonatomic, copy) UIButton *btn1;

@property (nonatomic, copy) UIView *bgView;
@property (nonatomic, copy) NSString *deliver_timesString;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.backgroundColor = [UIColor redColor];
    _btn.frame = CGRectMake(100, 200, 200, 45);
    [_btn addTarget:self action:@selector(Onclack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    
    _btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn1.backgroundColor = [UIColor redColor];
    _btn1.frame = CGRectMake(CGRectGetMinX(_btn.frame), CGRectGetMaxY(_btn.frame) + 50, 200, 45);
    [_btn1 addTarget:self action:@selector(Onclack1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn1];
    
    [self createCancleNotifation];
    [self createNotifation];

}

-(void)Onclack{
    NSLog(@"click...");
    [self.view endEditing:YES];
    
    [self createBackgroundView];
    
    [YTDatePick showPickWithMakeSure:^(id year, id month, id day) {
        [_btn setTitle:[NSString stringWithFormat:@"%@-%@-%@",year,month,day] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        self.delivery_time.text =[NSString stringWithFormat:@"%@年%@月%@日",year,month,day];
        self.deliver_timesString = [NSString stringWithFormat:@"%@%@%@",year,month,day];
        NSLog(@"deliver_timesString = %@",self.deliver_timesString);
    }];
}

-(void)Onclack1{
    NSLog(@"click1...");
    [self.view endEditing:YES];
    
    [self createBackgroundView];
    
    [YTDatePick showPickWithMakeSure:^(id year, id month, id day) {
        [_btn1 setTitle:[NSString stringWithFormat:@"%@-%@-%@",year,month,day] forState:UIControlStateNormal];
        [_btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        self.delivery_time.text =[NSString stringWithFormat:@"%@年%@月%@日",year,month,day];
        self.deliver_timesString = [NSString stringWithFormat:@"%@%@%@",year,month,day];
        NSLog(@"deliver_timesString1 = %@",self.deliver_timesString);
    }];
}

/**
 *  选择器背景阴影
 */
-(void)createBackgroundView{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.alpha = 0.3;
    _bgView.userInteractionEnabled = YES;
    [self.view addSubview:_bgView];
}

-(void)createCancleNotifation{
    if([self respondsToSelector:@selector(setCancleValueChanges)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCancleValueChanges) name:@"setCancleValueChanges" object:nil];
    }
}


-(void)createNotifation{
    if([self respondsToSelector:@selector(setCancleValueChanges)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCancleValueChanges) name:@"setInfor" object:nil];
    }
}


-(void)setCancleValueChanges {
    [_bgView removeFromSuperview];
    NSLog(@"取消了。。。");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
