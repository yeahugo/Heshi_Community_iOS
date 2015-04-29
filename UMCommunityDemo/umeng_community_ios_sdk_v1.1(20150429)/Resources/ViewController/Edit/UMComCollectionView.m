//
//  UMComCollectionView.m
//  UMCommunity
//
//  Created by umeng on 15-4-27.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComCollectionView.h"

@interface UMComCollectionView ()
@property (nonatomic, strong) NSArray *emojiNames;

@property (nonatomic, strong) NSArray *selectedEmojiNames;

@end

@implementation UMComCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        layout.itemSize = CGSizeMake(40, 40);
        layout.minimumInteritemSpacing = 2;
        layout.minimumLineSpacing = 2;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.backgroundColor  = [UIColor whiteColor];
        [self registerClass:[UMComCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        NSMutableArray *tempEmojis = [NSMutableArray arrayWithCapacity:1];
        for (int index = 1; index <= 105; index ++) {
            [tempEmojis addObject:[NSString stringWithFormat:@"Expression_%d",index]];
        }
        self.emojiNames = tempEmojis;
        self.selectedEmojiNames = [self emojiStringArray];
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.emojiNames.count;

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//- (NSInteger)numberOfItemsInSection:(NSInteger)section
//{
//}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UMComCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[UMComCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    }
    cell.emojiImage.image = [UIImage imageNamed:self.emojiNames[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectedAtImage) {
        self.didSelectedAtImage(self.selectedEmojiNames[indexPath.row]);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSArray *) emojiStringArray
{
    return @[
             @"[微笑]",@"[撇嘴]",@"[色]",@"[发呆]",@"[得意]",@"[流泪]",@"[害羞]",
             @"[闭嘴]",@"[睡]",@"[大哭]",@"[尴尬]",@"[发怒]",@"[调皮]",@"[呲牙]",
             @"[惊讶]",@"[难过]",@"[酷]",@"[冷汗]",@"[抓狂]",@"[吐]",@"[偷笑]",
             @"[愉快]",@"[白眼]",@"[傲慢]",@"[饥饿]",@"[困]",@"[惊恐]",@"[流汗]",
             
             @"[憨笑]",@"[悠闲]",@"[奋斗]",@"[咒骂]",@"[疑问]",@"[嘘]",@"[晕]",
             @"[疯了]",@"[衰]",@"[骷髅]",@"[敲打]",@"[再见]",@"[擦汗]",@"[抠鼻]",
             @"[鼓掌]",@"[糗大了]",@"[坏笑]",@"[左哼哼]",@"[右哼哼]",@"[哈欠]",@"[鄙视]",
             @"[委屈]",@"[快哭了]",@"[阴险]",@"[亲亲]",@"[吓]",@"[可怜]",@"[菜刀]",
             
             @"[西瓜]",@"[啤酒]",@"[篮球]",@"[乒乓]",@"[咖啡]",@"[饭]",@"[猪头]",
             @"[玫瑰]",@"[凋谢]",@"[嘴唇]",@"[爱心]",@"[心碎]",@"[蛋糕]",@"[闪电]",
             @"[炸弹]",@"[刀]",@"[足球]",@"[瓢虫]",@"[便便]",@"[月亮]",@"[太阳]",
             @"[礼物]",@"[拥抱]",@"[强]",@"[弱]",@"[握手]",@"[胜利]",@"[抱拳]",
             
             @"[勾引]",@"[拳头]",@"[差劲]",@"[爱你]",@"[NO]",@"[OK]",@"[爱情]",@"[飞吻]",
             @"[跳跳]",@"[发抖]",@"[怄火]",@"[转圈]",@"[磕头]",@"[回头]",@"[跳绳]",
             @"[投降]",@"[激动]",@"[乱舞]",@"[献吻]",@"[左太极]",@"[右太极]"
             ];
}
@end


@implementation UMComCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.emojiImage = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width/2-12, frame.size.height/2-12, 24, 24)];
        self.emojiImage.image = [UIImage imageNamed:@"fale"];
        [self.contentView addSubview:self.emojiImage];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
