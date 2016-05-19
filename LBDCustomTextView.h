//
//  LBDCustomTextView.h
//  LBDVshow
//
//  Created by xuyi on 16/5/6.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBDCustomTextView : UITextView

@property (nonatomic,strong)UILabel * placeholderLabel;

@property (nonatomic,copy)NSString * myPlaceholder;

@property (nonatomic,strong)UIFont * placeHolderFont;

@property (nonatomic,copy)NSString * textString;
@end
