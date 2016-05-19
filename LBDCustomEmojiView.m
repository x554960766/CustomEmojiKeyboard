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
        [self resetDasource];
        _faceButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 7, 26, 26)];
        [_faceButton setImage:[UIImage imageNamed:faceButtonImage] forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_faceButton];
        self.myTextView = [[LBDCustomTextView alloc]initWithFrame:CGRectMake(35, 2, frame.size.width - 88, 36)];
        self.myTextView .delegate = self;
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
        [layout setItemSize:CGSizeMake(frame.size.width/7-10, (210 - 20)/5)];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        // layout.sectionInset = UIEdgeInsetsMake(6,6,6, 6);
        
        mCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        mCollectionView.pagingEnabled = YES;
        mCollectionView.showsHorizontalScrollIndicator = NO;
        mCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        mCollectionView.backgroundColor = [UIColor clearColor];
        mCollectionView.dataSource = self;
        mCollectionView.delegate   = self;
        
        [mCollectionView registerClass:[LBDChatMessageFaceCollectionCell class] forCellWithReuseIdentifier:kReuseID];
        
        [self addSubview:mCollectionView];
        
        [mCollectionView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView: self.myTextView  withOffset:10];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
        [mCollectionView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
        mPageControl = [[UIPageControl alloc]initForAutoLayout];
        mPageControl.numberOfPages = (faceImageArray.count/28) +1;
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
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(faceViewFrame.origin.x , faceViewFrame.origin.y - 210, faceViewFrame.size.width ,faceViewFrame.size.height + 210);
        }];
    }
    else {
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

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LBDChatMessageFaceCollectionCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseID forIndexPath:indexPath];
    
    cell.model = self.DataSource[indexPath.row];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sendMessageString) {
        [self.sendMessageString appendString:_DataSource[indexPath.item][@"image"]];
    }
    else {
        self.sendMessageString = [[NSMutableString alloc]initWithString:_DataSource[indexPath.item][@"image"]];
    }
    NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
    [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
    self.myTextView .attributedText = textString;
    NSLog(@"选中了：%ld",(long)indexPath.item);
    //    if ([_delegate respondsToSelector:@selector(selectedFaceImage:)]) {
    //        [_delegate selectedFaceImage:_DataSource[indexPath.item][@"image"]];
    //    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == mCollectionView) {
        mPageControl.currentPage = (scrollView.contentOffset.x)/(scrollView.bounds.size.width - 10);
        
    }
}

#pragma mark - UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
 //   textView.selectedRange = NSMakeRange(_sendMessageString.length , 0);
    
    self.frame = CGRectMake(0,self.frame.origin.y,self.frame.size.width , 55);
    _faceButton.selected = NO;
    return  YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"range == %ld",range.location);
    if ([text lbd_containsEmoji]) {
        return  NO;
    }
    NSAttributedString * tempAtt = [  self.myTextView .attributedText attributedSubstringFromRange:NSMakeRange(0, range.location+range.length)];
    NSString * tempStr = [tempAtt changeToString];
    if (self.sendMessageString) {
        if (![text isEqualToString:@""]){
           
        
           [self.sendMessageString insertString:text atIndex:tempStr.length];
            
            //  textView.selectedRange = NSMakeRange(range.location, 0);
            //  [sendMessageString appendString:text];
        }
        else {
            
            if(range.length <= 1) {
                
                [self backFaceWithLocation:tempStr.length];
            }else {
                [self.sendMessageString replaceCharactersInRange:range withString:text];
            }
            
            
        }
    }
    else {
        self.sendMessageString = [[NSMutableString alloc]initWithString:text];
    }
    NSMutableAttributedString * textString = [[NSMutableAttributedString alloc]initWithAttributedString:[self.sendMessageString changeStringToAttribuedString]];
    [textString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, textString.length)];
     self.myTextView.text = _sendMessageString;
    self.myTextView .attributedText = textString;
   
    textView.selectedRange = NSMakeRange(range.location + text.length, 0);
    return  NO;   //禁止输入 防止显示错乱
}
-(void)sendButtonAction:(UIButton *)sendButton {
    [self.myTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = faceViewFrame;
    }];
    _faceButton.selected  = NO;
    if ([_delegate respondsToSelector:@selector(sendYouWriteMessage:)]) {
        
        [_delegate sendYouWriteMessage:self.sendMessageString];
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
    NSLog(@"键盘的frame:: %@",NSStringFromCGSize(keyBoardSize));
    
    [UIView animateWithDuration:0.25 animations:^{
        self.y = faceViewFrame.origin.y - keyBoardSize.height ;
    }];
    
}

- (void)keyboardWillHidden:(NSNotification *)noti{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.y = faceViewFrame.origin.y;
    }];
}

-(void)resetDasource {
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *finishArray = [[NSMutableArray alloc] init];
    // 判断表情是否铺满最后一页
    if ((_DataSource.count%28)<25) {
        int page = (int)(_DataSource.count/4)/7 ;
        for (int j = 28*page; j< _DataSource.count; j++) {
            [tempArray addObject:_DataSource[j] ];
        }
        int lineNumber = 0;
        for (int i = 0; i<tempArray.count; i++) {
            lineNumber = (i+1)/8;
            
            if (lineNumber == 0) {
                [finishArray addObject:tempArray[i]];
                for (int n = 0; n < 3; n++) {
                    [finishArray addObject:@{@"image":@""}];
                }
            }
            else {
                [finishArray replaceObjectAtIndex:  ((i+1)-8*lineNumber)*4+lineNumber withObject:tempArray[i]];
            }
        }
        NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
        for (int m =0; m<page*28; m++) {
            [mutableArray addObject:_DataSource[m]];
        }
        [mutableArray addObjectsFromArray:finishArray];
        
        _DataSource = mutableArray;
        //      int spaceImageNumber = 28*(page+1) - (int)mutable.count;
        
    }
    
}

//-(NSArray *)DataSource
//{
//    if (_DataSource) {
//        return _DataSource;
//    }
//
//    NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:_DataSource.count+8];
//
//    int del = 0;
//    for (int i=1; i<=_DataSource.count; i++)
//    {
//        if(((i+del)%(4*8 )))
//        {//增加删除按键
//            del ++;
//            [mutable addObject:@{@"image":@"aio_face_delete"}];
//        }
//
//        [mutable addObject:_DataSource[i]];
//    }
//
//    _DataSource = mutable;
//
//    return _DataSource;
//}


@end
