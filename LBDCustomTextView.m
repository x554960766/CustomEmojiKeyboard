//
//  LBDCustomTextView.m
//  LBDVshow
//
//  Created by xuyi on 16/5/6.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import "LBDCustomTextView.h"
#import "UIView+Extension.h"

@interface LBDCustomTextView ()

@end

@implementation LBDCustomTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor= [UIColor clearColor];
        
        UILabel *placeholderLabel = [[UILabel alloc]init];//添加一个占位label
        
        placeholderLabel.backgroundColor= [UIColor clearColor];
        
        placeholderLabel.numberOfLines=0; //设置可以输入多行文字时可以自动换行
        placeholderLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:placeholderLabel];
        
        self.placeholderLabel= placeholderLabel; //赋值保存
        
        
        self.font= [UIFont systemFontOfSize:16]; //设置默认的字体
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
        
      
       [self addSubview:placeholderLabel];
    }
    return self;
}

#pragma mark -监听文字改变

- (void)textDidChange {
    
    self.placeholderLabel.hidden = self.hasText;
    
}


- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.placeholderLabel.y=8; //设置UILabel 的 y值
    
    self.placeholderLabel.x=5;//设置 UILabel 的 x 值
    
    self.placeholderLabel.width=self.width-self.placeholderLabel.x*2.0; //设置 UILabel 的 x
    
    //根据文字计算高度
    
    CGSize maxSize =CGSizeMake(self.placeholderLabel.width,MAXFLOAT);
    
    self.placeholderLabel.height= [self.myPlaceholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeholderLabel.font} context:nil].size.height;
    
}


-(void)setMyPlaceholder:(NSString *)myPlaceholder{
    
    _myPlaceholder = [myPlaceholder copy];
    
    //设置文字
    
    self.placeholderLabel.text= myPlaceholder;
    
    //重新计算子控件frame
    
    [self setNeedsLayout];

}


- (void)setFont:(UIFont*)font{
    
    [super setFont:font];
    
    _placeholderLabel.font= font;
    
    //重新计算子控件frame
    
    [self setNeedsLayout];
    
}


- (void)setAttributedText:(NSAttributedString*)attributedText{
    
    [super setAttributedText:attributedText];
  
  
         [self textDidChange];
  
    
}


-(void)setLbd_placeHolder:(NSString *)lbd_placeHolder {
    
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:UITextViewTextDidChangeNotification];
    
}

-(NSString *)textString
{
    NSAttributedString * att = self.attributedText;
    
    NSMutableAttributedString * resutlAtt = [[NSMutableAttributedString alloc]initWithAttributedString:att];
    
    
 //   __weak __block my * copy_self = self;
    //枚举出所有的附件字符串
    [att enumerateAttributesInRange:NSMakeRange(0, att.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
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
