//
//  NSString + LBD.h
//  LBDVshow
//
//  Created by xuyi on 16/4/8.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LBD)
/// 判断字符串是否有效 (nil，全是空格，"null", "<null>", 都视为无效)
- (BOOL)lbd_isVailable;
/// 字符串是否包含表情
- (BOOL)lbd_containsEmoji;
/// 删除字符串内的表情符号，如果有则返回删除后的表情符号，如果没有，则返回nil
- (NSString *)lbd_removeEmojiWithContainsEmoji:(BOOL *)containsEmoji;

-(NSAttributedString *)changeStringToAttribuedString ;
@end

@interface NSNumber (LBD)

- (BOOL)lbd_isVailable;

@end

@interface NSNull (LBD)

- (BOOL)lbd_isVailable;

@end