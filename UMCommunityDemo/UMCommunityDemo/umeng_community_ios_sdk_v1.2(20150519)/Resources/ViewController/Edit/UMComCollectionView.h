//
//  UMComCollectionView.h
//  UMCommunity
//
//  Created by umeng on 15-4-27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMComCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, copy) void (^didSelectedAtImage)(NSString *imageName);

@end



@interface UMComCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *emojiImage;

@end