//
//  NSAttributedString + LBD.m
//  LBDVshow
//
//  Created by xuyi on 16/5/19.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import "NSAttributedString + LBD.h"

@implementation NSAttributedString (LBD)
-(NSString *)changeToString {
    NSMutableAttributedString * resutlAtt = [[NSMutableAttributedString alloc]initWithAttributedString:self];
    
    //枚举出所有的附件字符串
    [self enumerateAttributesInRange:NSMakeRange(0, self.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        //key-NSAttachment
        //NSTextAttachment value类型
        NSTextAttachment * textAtt = attrs[@"NSAttachment"];//从字典中取得那一个图片
        if (textAtt)
        {
            UIImage * image = textAtt.image;
            NSString * text = [self stringFromImage:image];
            [resutlAtt replaceCharactersInRange:range withString:text];
            
        }
        
    }];
    
    return resutlAtt.string;
    

}


//不能直接得到串的名字?
-(NSString *)stringFromImage:(UIImage *)image
{
    NSArray *face=[self getAllImagePaths];
    
    NSData * imageD = UIImagePNGRepresentation(image);
    
    NSString * imageName;
    
    for (int i=0; i<face.count; i++)
    {
        UIImage *image=[UIImage imageNamed:face[i]];
        NSData *data=UIImagePNGRepresentation(image);
        if ([imageD isEqualToData:data])
        {
            imageName=face[i];
            //NSLog(@"匹配成功!");
        }
    }
    
    
    return imageName;
}




-(NSArray *)getAllImagePaths//数组结构还是上述的截图的数组结构
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString * path = [bundle pathForResource:@"FaceList" ofType:@"plist"];
    
    NSArray * face = [[NSArray alloc]initWithContentsOfFile:path];
    
    return face;
}

@end
