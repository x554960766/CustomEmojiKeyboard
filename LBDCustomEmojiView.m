//
//  LBDCustomEmojiView.m
//  LBDVshow
//
//  Created by xuyi on 16/5/16.
//  Copyright © 2016年 汪宗奎. All rights reserved.
//

#define kUnSelectedColorPageControl   ([UIColor colorWithRed:0.604 green:0.608 blue:0.616 alpha:1])
#define kSelectedColorPageControl     ([UIColor colorWithRed:0.380 green:0.416 blue:0.463 alpha:1])

#define kReuseID             (@"faceCell")
#define UIColorHex(hex) [UIColor colorWithRed:((hex>>16)&0x0000FF)/255.0 green:((hex>>8)&0x0000FF)/255.0 blue:((hex>>0)&0x0000FF)/255.0 alpha:1.0]


#import "LBDCustomEmojiView.h"
#import "LBDChatMessageFaceCollectionCell.h"
#import "NSAttributedString + LBD.h"
#import "Masonry.h"
#import "NSString + LBD.h"
#import "UIView+Extension.h"

@interface LBDCustomEmojiView() <UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,UIScrollViewDelegate>
{
    UICollectionViewFlowLayout *layout ;
    CGRect  faceViewFrame ;
    UICollectionView *mCollectionView;
    UIPageControl    *mPageControl;
    UIView * dismissView ;
    NSAttributedString * tempAttributeString;  // 用了拼接临时使用
    NSInteger insertIndex; // 用来记录目前光标的位置
    
}
@property (nonatomic,strong) UIButton * faceButton;
@property (nonatomic,assign) CGFloat  keyboardHeight;
@property (nonatomic,strong) NSMutableString * sendMessageString;
@property(nonatomic,strong)  NSArray *DataSource;

@end

@implementation LBDCustomEmojiView




-(instancetype)initWithFrame:(CGRect)frame andFaceButtonImage:(NSString *)faceButtonImage andSendButtonImage:(NSString *)sendButtonImage andFaceImageNamesArray:(NSArray<NSDictionary *> *)faceImageArray {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
        faceViewFrame = frame;
        self.backgroundColor = [UIColor whiteColor];
        _DataSource = [faceImageArray copy];
        [self insertDelegateEmoji];
        [self resetDasource];
        _faceButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 11, 22, 22)];
        [_faceButton setImage:[UIImage imageNamed:faceButtonImage] forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_faceButton];
        self.myTextView = [[LBDCustomTextView alloc]initWithFrame:CGRectMake(46, 6, frame.size.width - 98, 32)];
        self.myTextView .delegate = self;
        //
        self.myTextView.font = [UIFont systemFontOfSize:18];
        self.myTextView .backgroundColor = [UIColor whiteColor];
        [self addSubview: self.myTextView ];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.myTextView.frame.size.height+5, frame.size.width, 1)];
        line.backgroundColor = UIColorHex(0xb4b4b4);
        [self addSubview:line];

        _sendButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 37, 11, 22, 22)];
        [_sendButton setImage:[UIImage imageNamed:sendButtonImage] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_sendButton];
        layout = [[UICollectionViewFlowLayout alloc]init];
        [layout setItemSize:CGSizeMake((frame.size.width - 20)/7, (190 - 30)/4)];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        mCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        mCollectionView.pagingEnabled = YES;
        mCollectionView.showsHorizontalScrollIndicator = NO;
        mCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        mCollectionView.backgroundColor = [UIColor clearColor];
        mCollectionView.dataSource = self;
        mCollectionView.delegate   = self;
        [mCollectionView registerClass:[LBDChatMessageFaceCollectionCell class] forCellWithReuseIdentifier:kReuseID];
        [self addSubview:mCollectionView];
        __weak typeof(self) weakSelf = self;
        [mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.myTextView.mas_bottom).with.offset(20);
            make.left.mas_equalTo(@10);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-30);
        }];
        
        mPageControl = [[UIPageControl alloc]init];
        mPageControl.numberOfPages = (faceImageArray.count/21) +1;
        mPageControl.userInteractionEnabled = NO;
        mPageControl.backgroundColor = [UIColor clearColor];
        mPageControl.currentPage  = 0;
        mPageControl.currentPageIndicatorTintColor = kSelectedColorPageControl;
        mPageControl.pageIndicatorTintColor  = kUnSelectedColorPageControl;
        [self addSubview:mPageControl];
        mPageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [mPageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(mCollectionView.center.x);
            make.top.equalTo(mCollectionView.mas_bottom).with.offset(-5);
        }];
        mPageControl.hidden = YES;
    }
    return self;
}

-(void)setKeyboardHeight:(CGFloat)keyboardHeight{
    _keyboardHeight = keyboardHeight;
}

-(void)setSendMessageString:(NSMutableString *)sendMessageString {
    _sendMessageString = sendMessageString;
}

-(void)faceButtonAction:(UIButton *)sender {
  
    [ self.myTextView  resignFirstResponder];
    _sendButton.selected = NO;
    sender.selected = !sender.selected;
    mPageControl.hidden = !sender.selected;
    
    if (sender.selected) {
        self.keyboardHeight = 190;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(faceViewFrame.origin.x , faceViewFrame.origin.y - 190, faceViewFrame.size.width ,faceViewFrame.size.height + 190);
        }];
    }
    else {
        self.keyboardHeight = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = faceViewFrame;
        }];
    }
    
    
}



#pragma mark - UICollectionView Delegate


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.DataSource.count;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,0,0,0);
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LBDChatMessageFaceCollectionCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseID forIndexPath:indexPath];
    
    cell.model = self.DataSource[indexPath.row];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        NSMutableAttributedString * textViewAttributeStr = self.myTextView.attributedText.mutableCopy;
        if ([@"[VS_DELETE]" isEqualToString:_DataSource[indexPath.item][@"image"]]) {
            if (insertIndex <= textViewAttributeStr.length && insertIndex > 0) {
                [textViewAttributeStr deleteCharactersInRange:NSMakeRange(insertIndex-1, 1)];
                insertIndex = insertIndex - 1;
            }
            
        }
        else {
            [textViewAttributeStr insertAttributedString:[_DataSource[indexPath.item][@"image"] changeToEmojiStringWithHaveReply:NO] atIndex:insertIndex];
            insertIndex = insertIndex + 1;
        }
        self.myTextView .attributedText = textViewAttributeStr;
        
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == mCollectionView) {
        mPageControl.currentPage = (scrollView.contentOffset.x)/(scrollView.bounds.size.width );
        
    }
}

#pragma mark - UITextViewDelegate


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.frame = CGRectMake(0,self.frame.origin.y,self.frame.size.width , 55);
    _faceButton.selected = NO;
    mPageControl.hidden = YES;
    _sendButton.selected = NO;
    if (textView.selectedTextRange) {
        insertIndex = textView.selectedRange.location;
    };
    
    return  YES;
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    //   insertIndex = textView.attributedText.length;
    if (textView.selectedTextRange) {
        if ([textView isFirstResponder]) {
            insertIndex = [textView selectedRange].location ;
        }
    } else {
        insertIndex = insertIndex + 1;
    }
    
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text lbd_containsEmoji]) {
        return  NO;
    }
    
    tempAttributeString = [text changeToEmojiStringWithHaveReply:NO];
    NSMutableAttributedString * textViewAttributeStr = self.myTextView.attributedText.mutableCopy;
    [textViewAttributeStr replaceCharactersInRange:range withAttributedString:tempAttributeString];
    self.myTextView.attributedText = textViewAttributeStr;
    if (text.length == 0) {
        textView.selectedRange = NSMakeRange(range.location , 0);
    }else {
        textView.selectedRange = NSMakeRange(range.location + text.length, 0);
        
    }
  
    
    return  NO;   //禁止输入 防止显示错乱
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (![textView hasText]) {
        _sendButton.selected = YES;
    }
    else {
        _sendButton.selected = NO;
    }
}


-(void)sendButtonAction:(UIButton *)sendButton {
    [self.myTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = faceViewFrame;
    }];
    self.keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
    _faceButton.selected  = NO;
    mPageControl.hidden = YES;
    if ([_delegate respondsToSelector:@selector(sendYouWriteMessage:)]) {
        insertIndex = 0; // 发送完成将 index 设置为0
        [_delegate sendYouWriteMessage:[_myTextView.attributedText changeToString]];
    }
}




#pragma mark   键盘显示时,改变这个输入框的位置的位置

- (void)keyboardWillShow:(NSNotification *)noti{
    
    CGSize keyBoardSize = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    self.keyboardHeight = keyBoardSize.height;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
    [UIView animateWithDuration:0.25 animations:^{
        self.y = faceViewFrame.origin.y - keyBoardSize.height ;
    }];
    
}

- (void)keyboardWillHidden:(NSNotification *)noti{
    self.keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
    [UIView animateWithDuration:0.25 animations:^{
        self.y = faceViewFrame.origin.y;
    }];
}

-(void)resetDasource {
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *finishArray = [[NSMutableArray alloc] init];
    // 判断表情是否铺满最后一页
    if ((_DataSource.count%21)) {
        int page = (int)(_DataSource.count/3)/7 ;
        for (int j = 21*page; j< _DataSource.count; j++) {
            [tempArray addObject:_DataSource[j] ];
        }
        int lineNumber = 0;
        for (int i = 0; i<tempArray.count; i++) {
            lineNumber = i/7;
            
            if (lineNumber == 0) {
                [finishArray addObject:tempArray[i]];
                for (int n = 0; n < 2; n++) {
                    [finishArray addObject:@{@"image":@""}];
                }
            }
            else {
                [finishArray replaceObjectAtIndex:  (i-7*lineNumber)*3+lineNumber withObject:tempArray[i]];
            }
        }
        NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
        for (int m =0; m<page*21; m++) {
            [mutableArray addObject:_DataSource[m]];
        }
        [mutableArray addObjectsFromArray:finishArray];
        
        _DataSource = mutableArray;
        //      int spaceImageNumber = 21*(page+1) - (int)mutable.count;
        
    }
    
}

-(void)insertDelegateEmoji {
    NSMutableArray *finishArray = [[NSMutableArray alloc] init];
    int del = 0;
    for (int i=1; i<=_DataSource.count; i++)
    {
        if(!((i+del)%(21)))
        {//增加删除按键
            del ++;
            [finishArray addObject:@{@"image":@"[VS_DELETE]"}];
        }
        
        [finishArray addObject:_DataSource[i-1]];
    }
    if ((_DataSource.count+del)%21) {
        [finishArray addObject:@{@"image":@"[VS_DELETE]"}];
    }
    _DataSource = finishArray.copy;
    
}

-(void)cleanTextView; {
    self.myTextView.attributedText = [[NSAttributedString alloc]initWithString:@""];
    self.myTextView.text = @"";
    if ([self.myTextView isFirstResponder]) {
        _sendButton.selected = NO;
    }
    else {
        _sendButton.selected = YES;
    }
    insertIndex = 0;
}

-(void)resignKeyboard;{
    
    if ([self.myTextView hasText]) {
        _sendButton.selected = NO;
    }
    else {
        _sendButton.selected = YES;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = faceViewFrame;
    }];
    self.keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
    _faceButton.selected  = NO;
    mPageControl.hidden = YES;
    [self.myTextView resignFirstResponder];
}





@end
