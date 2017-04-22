//
//  LBDCustomEmojiView.h
//  LBDVshow
//
//  Created by xuyi on 16/5/16.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBDCustomTextView.h"

@protocol LBDCustomEmojiViewDelegate <NSObject>
@required
-(void)sendYouWriteMessage:(NSString *)sendMessage;
@optional
-(void)selectedFaceImage:(NSString *)imageName;



@end

@interface LBDCustomEmojiView : UIView
/**
 *  显示表情键盘按钮
 */
@property (nonatomic,assign,readonly) CGFloat   keyboardHeight;
/**
 *  发送消息按钮
 */
@property (nonatomic,strong) UIButton * sendButton;
@property (nonatomic,strong,readonly)   NSMutableString * sendMessageString; // 用来发送的信息
@property (nonatomic, weak) id<LBDCustomEmojiViewDelegate> delegate ;
@property (nonatomic, strong)  LBDCustomTextView * myTextView ;
/**
 *  表情键盘的初始化
 *
 *  @param  输入框显示的大小
 *  @param faceButtonImage 显示表情键盘的按钮图片
 *  @param sendButtonImage 发送信息按钮的图片
 *  @param faceImageArray  表情数组 {image:string}
 *
 *  @return 表情键盘的初始化
 */
-(instancetype)initWithFrame:(CGRect)frame andFaceButtonImage:(NSString *)faceButtonImage andSendButtonImage:(NSString *)sendButtonImage andFaceImageNamesArray:(NSArray<NSDictionary *> *)faceImageArray;


/**
 *  收起键盘
 */
-(void)resignKeyboard;

@end
