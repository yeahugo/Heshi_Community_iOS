//
//  UMComOneFeedViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/12/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComTopicFeedViewController.h"
#import "UMComFeedsTableViewCell.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComFeedsTableView.h"
#import "UMComAction.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComShowToast.h"
#import "UMComUserRecommendViewController.h"
#import "UIViewController+UMComAddition.h"
@interface UMComTopicFeedViewController ()

@property (nonatomic, strong) NSMutableArray *resultArray;

@property (strong, nonatomic) UIButton *editedButton;

@property (nonatomic, strong) UMComUserRecommendViewController *recommendUsersVc;

@property (nonatomic, assign) NSInteger currentPage;

@end

#define DeltaBottom  45
#define DeltaRight 45

@implementation UMComTopicFeedViewController

-(id)initWithTopic:(UMComTopic *)topic
{
    self = [super initWithNibName:@"UMComTopicFeedViewController" bundle:nil];
    if (self) {
//        self.navigationItem.title = [NSString stringWithFormat:@"#%@#",topic.name];
       
        self.topic = topic;
        UMComTopicFeedsRequest *topicFeedsController = [[UMComTopicFeedsRequest alloc] initWithTopicId:topic.topicID  count:TotalTopicSize];
        self.fetchFeedsController = topicFeedsController;
   }
    return self;
}

- (void)setFocused:(BOOL)focused
{
    CALayer * downButtonLayer = [self.followButton layer];
    
    UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
    
    [downButtonLayer setBorderWidth:1.0];
    
    if([self isInclude:self.topic]){
        [downButtonLayer setBorderColor:[bcolor CGColor]];
        [self.followButton setTitleColor:bcolor forState:UIControlStateNormal];
        [self.followButton setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
    }else{
        [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
        [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.followButton setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
    }
}

- (BOOL)isInclude:(UMComTopic *)topic
{
    BOOL isInclude = NO;
    for (UMComTopic *topicItem in [UMComSession sharedInstance].focus_topics) {
        if ([topic.name isEqualToString:topicItem.name]) {
            isInclude = YES;
            break;
        }
    }
    return isInclude;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButtonWithTitle:UMComLocalizedString(@"Back", @"返回")];
    [self setTitleViewWithTitle:self.topic.name];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITapGestureRecognizer *tapToHidenKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self.feedsTableView action:@selector(dismissAllEditView)];
    [self.view addGestureRecognizer:tapToHidenKeyboard];
    
    [self.feedsTableView setViewController:self];
    
    [self setFocused:[self.topic isFocus]];
    
    if (self.topic.descriptor) {
        self.topicDescription.text = self.topic.descriptor;
    } else {
        self.topicDescription.text = self.topic.name;
    }
    
    [self.feedsTableView registerNib:[UINib nibWithNibName:@"UMComFeedsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FeedsTableViewCell"];

    __weak UMComTopicFeedViewController *weakSelf = self;
    
    self.feedsTableView.scrollViewDidScroll = ^(UIScrollView *scrollView, CGFloat lastPosition){
        
        if (scrollView.contentOffset.y >0 && scrollView.contentOffset.y > lastPosition+15) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                weakSelf.editedButton.center = CGPointMake(weakSelf.editedButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height+DeltaBottom);
            } completion:nil];
        }else{
            if (scrollView.contentOffset.y < lastPosition-15) {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    weakSelf.editedButton.center = CGPointMake(weakSelf.editedButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
                } completion:nil];
            }
        }
    };
    [self.topicFeedBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];

    
    self.editedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editedButton.frame = CGRectMake(0, 0, 50, 50);
    [self.editedButton setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
    [self.editedButton setImage:[UIImage imageNamed:@"new+"] forState:UIControlStateSelected];
    [self.editedButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.currentPage = 0;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.feedsTableView.hidden = NO;
    self.recommendUsersVc.view.hidden = NO;
    
    CGFloat viewHieght = self.focuBackgroundView.frame.size.height;
    CGSize textSize = [self.topicDescription.text sizeWithFont:self.topicDescription.font forWidth:self.topicDescription.frame.size.width lineBreakMode:NSLineBreakByCharWrapping];
    if (textSize.height > viewHieght) {
        viewHieght = textSize.height;
    }
    self.focuBackgroundView.frame = CGRectMake(self.focuBackgroundView.frame.origin.x, self.focuBackgroundView.frame.origin.y, self.focuBackgroundView.frame.size.width, viewHieght);
    self.followViewBackground.frame = CGRectMake(self.followViewBackground.frame.origin.x, self.followViewBackground.frame.origin.y, self.followViewBackground.frame.size.width, viewHieght+self.selectedSuperView.frame.size.height);
    self.topicDescription.frame = CGRectMake(self.topicDescription.frame.origin.x,0, self.topicDescription.frame.size.width, viewHieght);
    self.followButton.center = CGPointMake(self.followButton.center.x, self.focuBackgroundView.frame.size.height/2);
    
    if (self.currentPage == 0) {
        self.recommendUsersVc.view.frame = CGRectMake(self.feedsTableView.frame.size.width, self.feedsTableView.frame.origin.y, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        [self onClickTopicFeedsButton:self.topicFeedBt];
    }else{
        [self onClickHotUserFeedsButton:self.hotUserBt];
    }
    
    self.editedButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.editedButton];    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.feedsTableView dismissAllEditView];
    self.feedsTableView.hidden = YES;
    self.recommendUsersVc.view.hidden = YES;
    [self.editedButton removeFromSuperview];
}


-(IBAction)onClickFollow:(id)sender
{
    __weak UMComTopicFeedViewController *weakSelf = self;
    [self.topic setFocused:![self.topic isFocus] block:^(NSError * error) {
        if (!error) {
            [weakSelf setFocused:[weakSelf.topic isFocus]];
        }else{
            [UMComShowToast fetchFeedFail:error];
        }
    }];
}



- (IBAction)onClickEdit:(id)sender
{
   [[UMComEditAction action] performActionAfterLogin:self.topic viewController:self completion:nil];
}

- (IBAction)onClickTopicFeedsButton:(id)sender {
    self.currentPage = 0;
    CGFloat feedViewOriginY = self.followViewBackground.frame.origin.y + self.followViewBackground.frame.size.height;
    self.editedButton.frame = CGRectMake(self.view.frame.size.width-70, self.editedButton.frame.origin.y, 50, 50);
    self.editedButton.hidden = NO;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.feedsTableView.frame = CGRectMake(0, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.recommendUsersVc.view.frame = CGRectMake(self.feedsTableView.frame.size.width, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.selectedImageView.frame = CGRectMake(0, self.selectedImageView.frame.origin.y, self.topicFeedBt.frame.size.width, self.selectedImageView.frame.size.height);
        [self.topicFeedBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
        [self.hotUserBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } completion:nil];
    
    
}

- (IBAction)onClickHotUserFeedsButton:(id)sender {
    self.currentPage = 1;
    self.editedButton.hidden = YES;
    CGFloat feedViewOriginY = self.followViewBackground.frame.origin.y + self.followViewBackground.frame.size.height;
    if(!self.recommendUsersVc) {
        self.recommendUsersVc = [[UMComUserRecommendViewController alloc]init];
        self.recommendUsersVc.topicId = self.topic.topicID;
        self.recommendUsersVc.userDataSourceType = UMComTopicHotUser;
        self.recommendUsersVc.viewController = self;
        [self.view addSubview:self.recommendUsersVc.view];
        self.recommendUsersVc.view.frame = CGRectMake(self.feedsTableView.frame.size.width, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.recommendUsersVc.indicatorView.center = CGPointMake(self.recommendUsersVc.view.frame.size.width/2, self.recommendUsersVc.view.frame.size.height/2);
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.feedsTableView.frame = CGRectMake(-self.feedsTableView.frame.size.width, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.recommendUsersVc.view.frame = CGRectMake(0, feedViewOriginY, self.feedsTableView.frame.size.width, self.feedsTableView.frame.size.height);
        self.selectedImageView.frame = CGRectMake(self.topicFeedBt.frame.size.width, self.selectedImageView.frame.origin.y, self.topicFeedBt.frame.size.width, self.selectedImageView.frame.size.height);
        [self.hotUserBt setTitleColor:[UMComTools colorWithHexString:FontColorBlue] forState:UIControlStateNormal];
        [self.topicFeedBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } completion:nil];
}


- (void)loadDataFromCoreDataWithCompletion:(LoadDataCompletion)completion
{
    [self.fetchFeedsController fetchRequestFromCoreData:^(NSArray *data, NSError *error) {
        completion(data,error);
    }];
}

- (void)loadDataFromWebWithCompletion:(LoadDataCompletion)completion
{
    [self.fetchFeedsController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        completion(data,error);
    }];
}

- (void)loadMoreDataWithCompletion:(LoadDataCompletion)completion getDataFromWeb:(LoadServerDataCompletion)fromWeb
{
//    [self.fetchFeedsController fetchNextPageFromCoreData:^(NSArray *data, NSError *error) {
//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        completion(feeds.array,error);
//    }];
    [self.fetchFeedsController fetchNextPageFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
        fromWeb(data, haveNextPage, error);

//        NSOrderedSet *feeds = [self.topic performSelector:@selector(feeds)];
//        if (fromWeb) {
//            fromWeb(feeds.array, haveNextPage, error);
//        }
    }];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [(UMComFeedsTableView *)self.feedsTableView dismissAllEditView];
}

//#pragma mark UITableViewDelegate
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//     return  [(UMComFeedsTableView *)self.feedsTableView tableView:tableView heightForRowAtIndexPath:indexPath];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.feedsTableView scrollViewDidScroll:scrollView];
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self.feedsTableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
