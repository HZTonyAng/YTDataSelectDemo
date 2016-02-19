//
//  NSString+Tools.h
//  XinChuanBang
//
//  Created by TonyAng on 15/12/1.
//  Copyright © 2015年 xcb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Tools)

NSString * URLEncodedString(NSString *str);
NSString * MD5Hash(NSString *aString);

/**
 *  计算字符串 CGSize
 *
 *  @param font  字符串的 font
 *  @param maxSize
 *
 *  @return
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;


@property (nonatomic, copy)NSString *realString;
@end
