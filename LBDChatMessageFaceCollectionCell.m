#import "LBDChatMessageFaceCollectionCell.h"
#import "Masonry.h"

@interface LBDChatMessageFaceCollectionCell ()
{
    UIImageView *mImageView;
}
@end

@implementation LBDChatMessageFaceCollectionCell


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        mImageView = [[UIImageView alloc]init];
        mImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:mImageView];
        [mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];

    }
    return self;
}

-(void)setModel:(NSDictionary *)model
{
    _model = model;
    
    mImageView.image = [UIImage imageNamed:model[@"image"]];
}

@end
