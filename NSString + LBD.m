//
//  NSString + LBD.m
//  LBDVshow
//
//  Created by xuyi on 16/4/8.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import "NSString + LBD.h"

@implementation NSNumber (LBD)

- (BOOL)lbd_isVailable; {
    return YES;
}

@end

@implementation NSNull (LBD)

- (BOOL)lbd_isVailable; {
    return NO;
}
@end

@implementation NSString (LBD)

/// 判断字符串是否是空白
- (BOOL)lbd_isVailable; {
    return !(self.length <= 0
             || [self.lowercaseString isEqualToString:@"null"]
             || [self.lowercaseString isEqualToString:@"(null)"]
             || [self.lowercaseString isEqualToString:@"<null>"]
             || [self.lowercaseString isEqualToString:@"(null)"]
             || [self stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0 );
}


/// 字符串是否包含表情
- (BOOL)lbd_containsEmoji; {
    BOOL containsEmoji;
    [self lbd_removeEmojiWithStopWhenFind:YES containsEmoji:&containsEmoji];
    return containsEmoji;
}

- (NSString *)lbd_removeEmojiWithContainsEmoji:(BOOL *)containsEmoji; {
    return [self lbd_removeEmojiWithStopWhenFind:NO containsEmoji:containsEmoji];
}

/// 删除字符串内的表情符号，如果有则返回删除后的表情符号，如果没有，则返回nil
- (NSString *)lbd_removeEmojiWithStopWhenFind:(BOOL)stopWhenFind containsEmoji:(BOOL *)containsEmoji {
    if (containsEmoji != nil) { *containsEmoji = NO; }
    if (self.length == 0) { return self; }
    
    NSMutableString *result = [NSMutableString string];
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         BOOL haveEmoji = NO;
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     haveEmoji = YES;
                 }
             }
         }
         else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 haveEmoji = YES;
             }
         }
         else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 haveEmoji = YES;
             }
             else if (0x2B05 <= hs && hs <= 0x2b07) {
                 haveEmoji = YES;
             }
             else if (0x2934 <= hs && hs <= 0x2935) {
                 haveEmoji = YES;
             }
             else if (0x3297 <= hs && hs <= 0x3299) {
                 haveEmoji = YES;
             }
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 haveEmoji = YES;
             }
         }
         
         if (haveEmoji) {
             if (stopWhenFind) {
                 *stop = YES;
             }
         }
         else {
             [result appendString:substring];
         }
     }];
    
    // 判断是否包含Emoji
    if (containsEmoji != nil) {
        *containsEmoji = (result.length != self.length);
    }
    
    return result;
}


#define KFacialSizeWidth  18
#define KFacialSizeHeight 18



-(NSAttributedString *)changeStringToAttribuedString{
    BOOL haveFaceImage = false;
    NSMutableArray * textArray = [[NSMutableArray alloc] init];
    [self getImageRangeWithArray:textArray];
    int length = 0;
    NSAttributedString * tempAttributedString = [[NSAttributedString alloc]initWithString:@""];
    
    if (textArray) {
        for (int i = 0;i < [textArray count];i++) {
            NSString *str=[textArray objectAtIndex:i];
            
            
            // 因为回复人名只会出现在第一段里
            if ( i==0 ){
                for (int k = 0; k < str.length; k++) {
                    char tempChar = [str characterAtIndex:k];
                    
                    if (tempChar == ':') {
                        length = k - 7;
                        break;
                    }
                }
            }
            
            
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                //特别注意,根据括号长度写
                haveFaceImage = YES;
                NSString *imageName = [str substringWithRange:NSMakeRange(0, str.length)];
                //如果是以中括号开始和结束,但是找不到对应的表情,则显示原字符串
                UIImage *img = [UIImage imageNamed:imageName];
                if(!img){
                    //取出中括号中间的字符串
                    NSString *noImageStr = [str substringWithRange:NSMakeRange(0, str.length)];
                    NSAttributedString *normalAttStr = [[NSAttributedString alloc]initWithString:noImageStr ];
                    
                    NSMutableAttributedString *chatLabelAttStr = [[NSMutableAttributedString alloc]initWithAttributedString:tempAttributedString];
                    [chatLabelAttStr appendAttributedString:normalAttStr];
                    
                    tempAttributedString = chatLabelAttStr;
                    
                    continue;
                    
                }
                NSAttributedString *attachmentStr;
                if([DMDevceManager isiOS7]){
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
                    textAttachment.image = [UIImage imageNamed:imageName];
                    
                    textAttachment.bounds = CGRectMake(3, -4, KFacialSizeWidth, KFacialSizeHeight);
                    attachmentStr = [NSAttributedString attributedStringWithAttachment: textAttachment];
                }else {
                    attachmentStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%@]",imageName]];
                }
                NSMutableAttributedString *chatLabelAttributeStr = [[NSMutableAttributedString alloc]initWithAttributedString:tempAttributedString];
                [chatLabelAttributeStr appendAttributedString:attachmentStr];
                tempAttributedString = chatLabelAttributeStr;
            }
            else {
                NSAttributedString *normalAttStr = [[NSAttributedString alloc]initWithString:str ];
                NSMutableAttributedString *chatLabelAttStr = [[NSMutableAttributedString alloc]initWithAttributedString:tempAttributedString];
                [chatLabelAttStr appendAttributedString:normalAttStr];
                // 改变回复人的名字颜色
                if (length > 0 ) {
                    [chatLabelAttStr addAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]} range:NSMakeRange(6, length+1)];
                }
                
                tempAttributedString = chatLabelAttStr;
            }
        }
    }
    
    return tempAttributedString;
}

-(void)getImageRangeWithArray : (NSMutableArray*)array {
    NSRange range=[self rangeOfString: BEGIN_FLAG];
    NSRange range1=[self rangeOfString: END_FLAG];
    
    if (range.length > 0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[self substringToIndex:range.location]];//加文字
            [array addObject:[self substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];//加表情
            NSString *str=[self substringFromIndex:range1.location+1];
            [str getImageRangeWithArray: array];
        }
        else {
            NSString *nextstr=[self substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //NSLog(@"+++ nextStr %@",nextstr);
            
            //排除文字是“”的
            if (nextstr.length > 0) {
                [array addObject:nextstr];
                NSString *str=[self substringFromIndex:range1.location+1];
                [str getImageRangeWithArray: array];
            }else {
                return;
            }
        }
        
    } else if  (self != nil) {
        [array addObject:self];
    }
}


@end

