//
//  JPick.h
//  JPick
//
//  Created by xcb on 16/1/23.
//  Copyright © 2016年 xcb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTDatePick : UIView
@property (nonatomic, retain) NSDate *ScrollToDate;//滚到指定日期

+ (void)showPickWithMakeSure:(void(^)(id year, id month, id  day))selectArea;

@end
