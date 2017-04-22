//
//  NSAttributedString + LBD.h
//  LBDVshow
//
//  Created by xuyi on 16/5/19.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (LBD)

/// 转换为string
-(NSString *)changeToString;
-(NSString *)changeToStringDeteImage;
/**
 *  单纯改变一句话中的某些字的颜色
 *
 *  @param color    需要改变成的颜色
 *  @param totalStr 总的字符串
 *  @param subArray 需要改变颜色的文字数组
 *
 *  @return 生成的富文本
 */
+ (NSMutableAttributedString *)lbd_changeCorlorWithColor:(UIColor *)color TotalString:(NSString *)totalStr SubStringArray:(NSArray *)subArray;
/**
 *  同时更改行间距和字间距
 *
 *  @param totalString 需要改变的字符串
 *  @param lineSpace   行间距
 *  @param textSpace   字间距
 *
 *  @return 生成的富文本
 */
+ (NSMutableAttributedString *)lbd_changeLineAndTextSpaceWithTotalString:(NSString *)totalString LineSpace:(CGFloat)lineSpace textSpace:(CGFloat)textSpace;
/**
 *  改变某些文字的颜色 并单独设置其字体
 *
 *  @param font        设置的字体
 *  @param color       颜色
 *  @param totalString 总的字符串
 *  @param subArray    想要变色的字符数组
 *
 *  @return 生成的富文本
 */
+ (NSMutableAttributedString *)lbd_changeFontAndColor:(UIFont *)font Color:(UIColor *)color andlineSpace:(CGFloat)lineSpace TotalString:(NSString *)totalString SubStringArray:(NSArray *)subArray;

/**
 改变副文本的行间距和文字间距

 @param lineSpace 行间距
 @param textSpace 文字间距
 @return 生成的富文本
 */
-(NSMutableAttributedString *)lbd_changeTextLineSpace:(CGFloat)lineSpace andTextSpace:(CGFloat)textSpace;
@end
