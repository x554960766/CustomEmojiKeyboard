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

#import "LBDCustomEmojiView.h"
#import "LBDChatMessageFaceCollectionCell.h"
#import "PureLayout.h"
#import "NSAttributedString + LBD.h"

@interface LBDCustomEmojiView() <UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,UIScrollViewDelegate>
{
    UICollectionViewFlowLayout *layout ;
    
    
    UIView * customSendMessageView;
    CGRect  faceViewFrame ;
    UICollectionView *mCollectionView;
    UIPageControl    *mPageControl;
    UIView * dismissView ;
    NSMutableAttributedString * textViewAttributedString; //当前textView显示的字
    NSAttributedString * tempAttributeString;  // 用了拼接临时使用
    NSInteger insertIndex; // 用来记录目前光标的位置
    
}
@property(nonatomic,strong)NSArray *DataSource;
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
        _faceButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 7, 26, 26)];
        [_faceButton setImage:[UIImage imageNamed:faceButtonImage] forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_faceButton];
        self.myTextView = [[LBDCustomTextView alloc]initWithFrame:CGRectMake(35, 2, frame.size.width - 88, 36)];
        self.myTextView .delegate = self;
        self.myTextView.font = [UIFont systemFontOfSize:18];
        self.myTextView .backgroundColor = [UIColor whiteColor];
        [self addSubview: self.myTextView ];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.myTextView.bottomY+5, frame.size.width, 1)];
        line.backgroundColor = Color(240, 240, 240);
        [self addSubview:line];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake( self.myTextView .bottomX+5,5, 1, 30)];
        lineView.backgroundColor = Color(240, 240, 240);
        [self addSubview:lineView];
        
        _sendButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 35, 5, 30, 30)];
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
        [mCollectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView: self.myTextView  withOffset:20];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:30];
        mPageControl = [[UIPageControl alloc]initForAutoLayout];
        mPageControl.numberOfPages = (faceImageArray.count/21) +1;
        mPageControl.userInteractionEnabled = NO;
        mPageControl.backgroundColor = [UIColor clearColor];
        mPageControl.currentPage  = 0;
        mPageControl.currentPageIndicatorTintColor = kSelectedColorPageControl;
        mPageControl.pageIndicatorTintColor  = kUnSelectedColorPageControl;
        [self addSubview:mPageControl];
        mPageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [mPageControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [mPageControl autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mCollectionView withOffset:-10];
        mPageControl.hidden = YES;
    }
    return self;
}



-(void)faceButtonAction:(UIButton *)sender {
    [ self.myTextView  resignFirstResponder];
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
             [textViewAttributeStr insertAttributedString:[_DataSource[indexPath.item][@"image"] changeStringToAttribuedString] atIndex:insertIndex];
             insertIndex = insertIndex + 1;
         }
     self.myTextView .attributedText = textViewAttributeStr;
    /*
    if ([@"[VS_DELETE]" isEqualToString:_DataSource[indexPath.item][@"image"]]) {
        if (self.sendMessageString) {
            if (self.sendMessageString.length > 0) {
                 [self backFaceWithLocation:self.sendMessageString.length];
            }
        }
        
    }else{
        
        if (self.sendMessageString) {
            [self.sendMessageString appendString:_DataSource[indexPath.item][@"image"]];
        }
        else {
            self.sendMessageString = [[NSMutableString alloc]initWithString:_DataSource[indexPath.item][@"image"]];
        }
    }
    NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
    [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
    self.myTextView .attributedText = textString;
    NSLog(@"选中了：%ld",(long)indexPath.item);
    //    if ([_delegate respondsToSelector:@selector(selectedFaceImage:)]) {
    //        [_delegate selectedFaceImage:_DataSource[indexPath.item][@"image"]];
    //    }
     */
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
    
    if(textViewAttributedString == nil) {
        tempAttributeString = [text changeStringToAttribuedString];
     //   textViewAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:tempAttributeString];
    }
    else {
         tempAttributeString = [text changeStringToAttribuedString];
    //    [textViewAttributedString appendAttributedString:tempAttributeString];
    }
    NSMutableAttributedString * textViewAttributeStr = self.myTextView.attributedText.mutableCopy;
    [textViewAttributeStr replaceCharactersInRange:range withAttributedString:tempAttributeString];
   
    self.myTextView.attributedText = textViewAttributeStr;
     textView.selectedRange = NSMakeRange(range.location + text.length, 0);
    
    /*
    NSAttributedString * tempAtt = [ self.myTextView .attributedText attributedSubstringFromRange:range];
    NSString * tempStr = [tempAtt changeToString];
    if (self.sendMessageString) {
        if (![text isEqualToString:@""]){
            
            
            [self.sendMessageString insertString:text atIndex:tempStr.length];
            NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
            [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
            self.myTextView.text = _sendMessageString;
            self.myTextView .attributedText = textString;
            
            //  textView.selectedRange = NSMakeRange(range.location, 0);
            //  [sendMessageString appendString:text];
        }
        else {
            
            if(range.length <= 1) {
                
                [self backFaceWithLocation:tempStr.length];
                if (self.myTextView .attributedText.length > 0){
                    self.myTextView .attributedText = [self.myTextView.attributedText attributedSubstringFromRange:NSMakeRange(0, self.myTextView.attributedText.length - range.length)];
                }
            }else {
                [self.sendMessageString replaceCharactersInRange:range withString:text];
                NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
                [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
                self.myTextView.text = _sendMessageString;
                self.myTextView .attributedText = textString;
            }
        }
    }
    else {
        self.sendMessageString = [[NSMutableString alloc]initWithString:text];
        NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
        [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
        self.myTextView.text = _sendMessageString;
        self.myTextView .attributedText = textString;
    }
    
    
    textView.selectedRange = NSMakeRange(range.location + text.length, 0);
     */
    return  NO;   //禁止输入 防止显示错乱
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



-(void)btnClick:(UIButton *)sender
{
    //sender.selected = !sender.selected;
}



// 删除输入字符（对删除表情做特殊处理 需要优化）
- (void)backFaceWithLocation:(NSInteger)location{
    if (location==0) {
        return;
    }
    NSString *firstString;
    NSString *secondString;
    if (self.sendMessageString) {
        firstString = [self.sendMessageString substringToIndex:location ];
        secondString = [self.sendMessageString substringFromIndex:location];
    }
    NSMutableString * finishString;
    NSString *string = nil;
    NSInteger stringLength = firstString.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[firstString substringFromIndex:stringLength-1]]) {
            if ([firstString rangeOfString:@"["].location == NSNotFound){
                string = [firstString substringToIndex:stringLength - 1];
            } else {
                string = [firstString substringToIndex:[firstString rangeOfString:@"[" options:NSBackwardsSearch].location];
            }
        } else {
            string = [firstString stringByReplacingCharactersInRange:NSMakeRange(location-1, 1) withString:@""];
        }
    }
    finishString = [[NSMutableString alloc]initWithString:string];
    [finishString appendString:secondString];
    self.sendMessageString = finishString;
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


-(void)resignKeyboard;{
    [self.myTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = faceViewFrame;
    }];
    self.keyboardHeight = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customKeyboardHeight" object:[NSNumber numberWithFloat:self.keyboardHeight]];
    _faceButton.selected  = NO;
    mPageControl.hidden = YES;}


@end
