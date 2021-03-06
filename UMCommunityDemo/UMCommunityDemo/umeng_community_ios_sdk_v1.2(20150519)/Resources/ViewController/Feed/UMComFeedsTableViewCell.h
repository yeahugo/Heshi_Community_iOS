//
//  UMComFeedsTableViewCell.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComFeed.h"
#import "UMComGridView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComFeedStyle.h"
#import "UMComImageView.h"

@interface UMComFeedsTableViewCell : UITableViewCell
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *fakeTextView;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *fakeOriginTextView;

@property (nonatomic, weak) IBOutlet UMComGridView * gridView;

@property (nonatomic, weak) IBOutlet UMComMutiStyleTextView *likeListTextView;

@property (weak, nonatomic) IBOutlet UIView *likeImageBgVIew;

@property (nonatomic, weak) IBOutlet UIImageView *imagesBackGroundView;

@property (nonatomic, strong) UMComImageView * avatarImageView;

@property (nonatomic, strong) UILabel * likeCountLabel;

@property (nonatomic, weak) IBOutlet UILabel * dateLabel;

@property (nonatomic, weak) IBOutlet UILabel * locationLabel;

@property (nonatomic, weak) IBOutlet UIView * locationBackground;

@property (nonatomic, weak) IBOutlet UIView *editBackGround;

@property (nonatomic, weak) IBOutlet UIButton *showEditBackGround;

@property (nonatomic, weak) IBOutlet UITableView *commentTableView;

@property (nonatomic, weak) IBOutlet UIButton *likeButton;

@property (nonatomic, strong) UIView *seperateView;

@property (nonatomic, strong) NSArray *reloadComments;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UMComFeed *feed;

- (IBAction)onClickUserProfile:(id)sender;

- (IBAction)onClickEdit:(id)sender;

- (void)reload:(UMComFeed *)feed tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath feedStyle:(UMComFeedStyle *)feedStyle;

+ (UMComFeedStyle *)getCellHeightWithFeed:(UMComFeed *)feed isShowComment:(BOOL)isShowComment tableViewWidth:(float)viewWidth;

- (void)dissMissEditBackGround;

- (IBAction)onClickComment:(id)sender;

- (IBAction)onClickLike:(id)sender;

- (IBAction)onClickForward:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *acounTypeLabel;
- (void)showMoreComments;


@end
