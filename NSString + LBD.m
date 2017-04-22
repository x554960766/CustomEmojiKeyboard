//
//  NSString + LBD.m
//  LBDVshow
//
//  Created by xuyi on 16/4/8.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import "NSString + LBD.h"
#import <CoreText/CoreText.h>

#define UIColorHex(hex) [UIColor colorWithRed:((hex>>16)&0x0000FF)/255.0 green:((hex>>8)&0x0000FF)/255.0 blue:((hex>>0)&0x0000FF)/255.0 alpha:1.0]


#define KFacialSizeWidth  14
#define KFacialSizeHeight 14

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



+(NSAttributedString *)returnAttributedStringWithImageName:(NSString *)imageName andImageRect:(CGRect)imageRect {
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
    textAttachment.image = [UIImage imageNamed:imageName];
    textAttachment.bounds = imageRect;
    NSAttributedString * tempAttrat = [NSAttributedString attributedStringWithAttachment:textAttachment];
    return tempAttrat;
}


/// 判断字符串是否是空白
- (BOOL)lbd_isVailable; {
    return !(self.length <= 0
             || [self.lowercaseString isEqualToString:@"null"]
             || [self.lowercaseString isEqualToString:@"(null)"]
             || [self.lowercaseString isEqualToString:@"<null>"]
             || [self.lowercaseString isEqualToString:@"(null)"]
             ||([self isKindOfClass:[NSNull class]])
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


-(NSString *)formatThousandString {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: [self integerValue]]];
    return numberString;
}


-(NSAttributedString *)changeToEmojiStringWithHaveReply:(BOOL)haveReply {
    static UIImage * tempImage = nil;
   
    NSMutableAttributedString * strAtt = [[NSMutableAttributedString alloc]initWithString:self];
 
    NSString * pattern = @"\\[[_A-Za-z0-9]+\\]";
    NSError *error = nil;
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    for (NSInteger i = results.count - 1; i >= 0; i--) {
        NSTextCheckingResult * result = results[i];
        NSString * imgStr = [strAtt.string substringWithRange:result.range];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
        tempImage = [UIImage imageNamed:imgStr];
        textAttachment.image = tempImage;
        textAttachment.bounds = CGRectMake(0, -3, KFacialSizeHeight*(tempImage.size.width/tempImage.size.height), KFacialSizeHeight);
        NSAttributedString * strImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [strAtt replaceCharactersInRange:result.range withAttributedString:strImage];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [strAtt addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, strAtt.length)];
    
    return  strAtt;
}



-(NSAttributedString *)returnAttributedStringWithImageName:(NSString *)imageName andImageRect:(CGRect)imageRect andInsertLocation:(NSInteger)location {
    NSMutableAttributedString * finish = [[NSMutableAttributedString alloc]initWithString:self];
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];
    textAttachment.image = [UIImage imageNamed:imageName];
    textAttachment.bounds = imageRect;
    NSAttributedString * tempAttrat = [NSAttributedString attributedStringWithAttachment:textAttachment];
    if (location>self.length) {
        [finish insertAttributedString:tempAttrat atIndex:self.length];
    }
    else {
        [finish insertAttributedString:tempAttrat atIndex:location];
    }
    return finish;
}


@end

