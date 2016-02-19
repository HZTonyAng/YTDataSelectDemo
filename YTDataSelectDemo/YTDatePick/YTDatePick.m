//
//  JPick.m
//  JPick
//
//  Created byxcb on 16/1/23.
//  Copyright © 2016年 xcb. All rights reserved.
//

#import "YTDatePick.h"
#import "YTDatePicker_DateModel.h"
#import <objc/runtime.h>
#import "NSString+Tools.h"
#define Window_Root [[[[UIApplication sharedApplication] delegate] window] bounds].size
#define Window [[[UIApplication sharedApplication] delegate] window]
#define kColorNAVI_BULE  [UIColor colorWithRed:46 / 255.f green:186/ 255.f blue:238 / 255.f alpha:1.f]
#define UUPICKER_MAXDATE 2018
#define UUPICKER_MINDATE 2016

@interface YTDatePick(){
    /**
     *  记录位置
     *
     */
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    NSArray *_indexArray;
}

@property (nonatomic, assign) BOOL isMySelect;

@end

@interface NSNumber (StringValue)

//@property (nonatomic, copy)NSString *string;

@end


@implementation NSNumber (StringValue)

- (NSString *)string{
    if (self.integerValue >= 10) {
        return [NSString stringWithFormat:@"%@", self];
    }else{
        return [NSString stringWithFormat:@"0%@", self];
    }
}

@end

@interface MyPickViews: UIPickerView<UIPickerViewDelegate,UIPickerViewDataSource>

- (void)showPickViewWithFrame:(CGRect )frame
                     delegate:(id)delegate
                      supView:(UIView *)supView
      numberOfRowsInComponent:(NSInteger(^)(NSInteger component))numberOfRowsInComponent
                  titleForRow:(UIView *(^)(NSInteger row, NSInteger component))titleForRow
                 didSelectRow:(void(^)(NSInteger row, NSInteger component))didSelectRow;

@property (nonatomic, copy)NSInteger(^numberOfRowsInComponent)(NSInteger  component);
@property (nonatomic, copy)UIView *(^titleForRow)(NSInteger row, NSInteger component);
@property (nonatomic, copy)void(^didSelectRow)(NSInteger row, NSInteger component);


@end



@implementation MyPickViews


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (void)showPickViewWithFrame:(CGRect)frame delegate:(id)delegate supView:(UIView *)supView numberOfRowsInComponent:(NSInteger (^)(NSInteger ))numberOfRowsInComponent titleForRow:(UIView *(^)(NSInteger, NSInteger))titleForRow didSelectRow:(void (^)(NSInteger, NSInteger))didSelectRow{
    self.delegate = self;
    self.dataSource = self;
    self.frame = frame;
    
    
    if ([supView.subviews containsObject:self]) {
        
    }else {
        [supView addSubview:self];
    }
    self.numberOfRowsInComponent = numberOfRowsInComponent;
    self.titleForRow = titleForRow;
    self.didSelectRow = didSelectRow;
    
    NSLog(@"%@", self.titleForRow);
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.numberOfRowsInComponent) {
        return self.numberOfRowsInComponent(component);
    }else{
        return 0;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.didSelectRow(row , component);
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    [pickerView.subviews[1] setBackgroundColor:kColorNAVI_BULE];
    [pickerView.subviews[2] setBackgroundColor:kColorNAVI_BULE];
    
    return self.titleForRow(row, component);
}
@end

static void(^dayClickSureBlock)(id, id, id);

@interface YTDatePick ()

@property (nonatomic, strong)MyPickViews *firstTable, *secondTable, *thirdTable;
@property (nonatomic, assign)NSInteger fistSelect, secSelect,thirdSelect;
@property (nonatomic, strong)NSArray *dataArr;
@end

@implementation YTDatePick

- (UIPickerView *)firstTable{
    if (!_firstTable) {
        self.firstTable = [MyPickViews new];
    }
    return _firstTable;
}
- (UIPickerView *)secondTable{
    if (!_secondTable) {
        self.secondTable = [MyPickViews new];
    }
    return _secondTable;
}
- (UIPickerView *)thirdTable{
    if (!_thirdTable) {
        self.thirdTable = [MyPickViews new];
    }
    return _thirdTable;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //获取当前日期，储存当前时间位置
        _indexArray = [self getNowDate:self.ScrollToDate];
        self.fistSelect = (int)[_indexArray[0] integerValue];
        self.secSelect = (int)[_indexArray[1] integerValue];
        self.thirdSelect = (int)[_indexArray[2] integerValue];
        
        [self configuesubViews];
        //网络请求方法
        _isMySelect = YES;
        [self networkWithURL:nil];
        
        [self addObserver:self forKeyPath:@"fistSelect" options:(NSKeyValueObservingOptionNew) context:nil];
        [self addObserver:self forKeyPath:@"secSelect" options:(NSKeyValueObservingOptionNew) context:nil];
        [self addObserver:self forKeyPath:@"thirdSelect" options:(NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [self networkWithURL:nil];
}

+ (void)showPickWithMakeSure:(void (^)(id, id, id))selectArea{
    dayClickSureBlock = selectArea;
    YTDatePick *pick = [Window viewWithTag:999];
    if (!pick) {
        pick = [[YTDatePick alloc] initWithFrame:CGRectMake(0, 0, Window_Root.width, Window_Root.height)];
        pick.tag = 999;
        [Window addSubview:pick];
    }
    else{
        //        pick.hidden = NO;
        [pick removeFromSuperview];
    }
}

- (void)networkWithURL:(NSString *)urlStr{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"daysList"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        [self handleDataWithDic:array];
        //获取当前日期，储存当前时间位置
        _indexArray = [self getNowDate:self.ScrollToDate];
        NSLog(@"++++%d", (int)[_indexArray[0] integerValue]);
        NSLog(@"++++%d", (int)[_indexArray[1] integerValue]);
        NSLog(@"++++%d", (int)[_indexArray[2] integerValue]);
        //调整为现在的时间
        if (_isMySelect) {
            _isMySelect = NO;
            [_firstTable selectRow:(int)[_indexArray[0] integerValue] inComponent:0 animated:YES];
            [_secondTable selectRow:(int)[_indexArray[1] integerValue] inComponent:0 animated:YES];
            [_thirdTable selectRow:(int)[_indexArray[2] integerValue] inComponent:0 animated:YES];
        }
        
    }else{
        [self daysWithPath:path];
    }
}

bool LeepYear(int year){
    if (year % 100 == 0 ) {
        if (year % 400 == 0) {
            return 1;
        }
        return 0;
    }else if (year % 4 == 0){
        return 1;
    }else{
        return 0;
    }
}

- (void)daysWithPath:(NSString *)path{
    //年数组
    NSMutableArray *yearArray = [@[] mutableCopy];
    
    //设置年开始时间和结束年
    for (int i = UUPICKER_MINDATE; i <= UUPICKER_MAXDATE; i ++) {
        [yearArray addObject:@(i)];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dataSource = [@[] mutableCopy];
        for (NSNumber *year in yearArray) {
            NSArray *temArray = @[@31, LeepYear(year.intValue) ? @29 : @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31];
            NSMutableArray *monthArray = [@[] mutableCopy];
            for (int i = 1; i < 13; i ++) {
                
                NSMutableArray *daysArray = [@[] mutableCopy];
                
                for (int j = 1; j <= [temArray[i - 1] integerValue]; j ++) {
                    @autoreleasepool {
                        [daysArray addObject:@(j)];
                    }
                }
                
                @autoreleasepool {
                    NSDictionary *dic = @{@"month":@(i), @"daysList": daysArray};
                    [monthArray addObject:dic];
                }
            }
            [dataSource addObject:@{@"year" : year, @"monthList":monthArray}];
        }
        [dataSource writeToFile:path atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleDataWithDic:dataSource];
            [_firstTable reloadAllComponents];
            [_secondTable reloadAllComponents];
            [_thirdTable reloadAllComponents];
            
            //获取当前日期，储存当前时间位置
            _indexArray = [self getNowDate:self.ScrollToDate];
            NSLog(@"++++%d", (int)[_indexArray[0] integerValue]);
            NSLog(@"++++%d", (int)[_indexArray[1] integerValue]);
            NSLog(@"++++%d", (int)[_indexArray[2] integerValue]);
            if (_isMySelect) {
                _isMySelect = NO;
                [_firstTable selectRow:(int)[_indexArray[0] integerValue] inComponent:0 animated:YES];
                [_secondTable selectRow:(int)[_indexArray[1] integerValue] inComponent:0 animated:YES];
                [_thirdTable selectRow:(int)[_indexArray[2] integerValue] inComponent:0 animated:YES];
            }
        });
    });
}

- (void)handleDataWithDic:(NSArray *)array{
    self.dataArr = [NSMutableArray arrayWithArray:array];
    [self.firstTable showPickViewWithFrame:CGRectMake(25, Window_Root.height - 220, Window_Root.width / 3.0 - 35, 150) delegate:self supView:self numberOfRowsInComponent:^NSInteger(NSInteger component) {
        return self.dataArr.count;
    } titleForRow:^UIView *(NSInteger row, NSInteger component) {
        NSDictionary *model = self.dataArr[row];
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%@年", model[@"year"]];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    } didSelectRow:^(NSInteger row, NSInteger component) {
        self.fistSelect = row;
    }];
    
    [self.secondTable showPickViewWithFrame:CGRectMake(Window_Root.width / 3.0 + 15, Window_Root.height - 220, Window_Root.width / 3.0 - 35, 150) delegate:self supView:self numberOfRowsInComponent:^NSInteger(NSInteger component) {
        return 12;
    } titleForRow:^UIView *(NSInteger row, NSInteger component) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%@月",@(row + 1).string];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    } didSelectRow:^(NSInteger row, NSInteger component) {
        self.secSelect = row;
    }];
    
    [self.thirdTable showPickViewWithFrame:CGRectMake(Window_Root.width / 3.0 * 2 , Window_Root.height - 220, Window_Root.width / 3.0 - 35, 150) delegate:self supView:self numberOfRowsInComponent:^NSInteger(NSInteger component) {
        NSArray *monthDic = self.dataArr[self.fistSelect][@"monthList"];
        NSArray *dayList = monthDic[self.secSelect][@"daysList"];
        return dayList.count;
        
    } titleForRow:^UIView *(NSInteger row, NSInteger component) {
        NSArray *monthDic = self.dataArr[self.fistSelect][@"monthList"];
        NSArray *dayList = monthDic[self.secSelect][@"daysList"];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%@日", ((NSNumber *)dayList[row]).string];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    } didSelectRow:^(NSInteger row, NSInteger component) {
        
    }];
}
- (void)configuesubViews{
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(20, Window_Root.height - 240, Window_Root.width - 50, 168)];
    back.backgroundColor = [UIColor whiteColor];
    back.layer.cornerRadius = 3;
    back.clipsToBounds = YES;
    [self addSubview:back];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Window_Root.width-50, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"选择时间";
    label.font = [UIFont systemFontOfSize:18.0];
    [back addSubview:label];
    
    [self createButtonWithFrame:CGRectMake(20, self.bounds.size.height - 60, self.bounds.size.width / 2 - 30, 42) title:@"取 消" action:@selector(cancleClick)];
    
    [self createButtonWithFrame:CGRectMake(self.bounds.size.width / 2 , self.bounds.size.height - 60, self.bounds.size.width / 2 - 30, 42) title:@"确 定" action:@selector(makeSure)];
}

- (void)createButtonWithFrame:(CGRect )rect title:(NSString *)title action:(SEL)acrion{
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancleBtn.frame = rect;
    [cancleBtn setTitle:title forState:(UIControlStateNormal)];
    cancleBtn.backgroundColor = [UIColor whiteColor];
    [cancleBtn setTitleColor:kColorNAVI_BULE forState:(UIControlStateNormal)];
    cancleBtn.layer.cornerRadius = 3;
    cancleBtn.clipsToBounds = YES;
    [cancleBtn addTarget:self action:acrion forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:cancleBtn];
}
/**
 *  取消
 */
- (void)cancleClick{
    YTDatePick *pick = [Window viewWithTag:999];
    //    pick.hidden = YES;
    [pick removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setInfor" object:nil];
}
/**
 *  确定
 */
- (void)makeSure{
    NSString *year = self.dataArr[self.fistSelect][@"year"];
    
    NSArray *monthDic = self.dataArr[self.fistSelect][@"monthList"];
    NSArray *dayList = monthDic[self.secSelect][@"daysList"];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)[self.secondTable selectedRowInComponent:0] + 1];
    NSString *day = dayList[[self.thirdTable selectedRowInComponent:0]];
    
    dayClickSureBlock(@(year.integerValue).string, @(month.integerValue).string, @(day.integerValue).string);
    NSLog(@"%@%@%@", @(year.integerValue).string, @(month.integerValue).string, @(day.integerValue).string);
    [self cancleClick];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setCancleValueChanges" object:nil];
}

//获取当前时间解析及位置
- (NSArray *)getNowDate:(NSDate *)date
{
    NSDate *dateShow;
    if (date) {
        dateShow = date;
    }else{
        dateShow = [NSDate date];
    }
    YTDatePicker_DateModel *model = [[YTDatePicker_DateModel alloc]initWithDate:dateShow];
    yearIndex = [model.year intValue]-UUPICKER_MINDATE;
    monthIndex = [model.month intValue]-1;
    dayIndex = [model.day intValue]-1;
    NSNumber *year   = [NSNumber numberWithInteger:yearIndex];
    NSNumber *month  = [NSNumber numberWithInteger:monthIndex];
    NSNumber *day    = [NSNumber numberWithInteger:dayIndex];
    return @[year,month,day];
}

@end
