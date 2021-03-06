//
//  UMComHomeFeedViewController.m
//  UMCommunity
//
//  Created by umeng on 15-4-2.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComHomeFeedViewController.h"
#import "UMComAllFeedViewController.h"
#import "UMComNavigationController.h"
#import "UMComSearchBar.h"
#import "UMComFeedsTableView.h"
#import "UMComAction.h"
#import "UMComPageControlView.h"
#import "UMComFilterTopicsViewController.h"
#import "UMComSearchViewController.h"
#import "UIViewController+UMComAddition.h"


#define kTagRecommend 100
#define kTagAll 101

#define DeltaBottom  45
#define DeltaRight 45

@interface UMComHomeFeedViewController ()<UISearchBarDelegate>


@property (strong, nonatomic) UMComSearchBar *topicSearchBar;

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UMComFeedsTableView *tempfeedTableView;
@property (nonatomic, strong) UMComAllFeedViewController *allFeedViewController;
@property (nonatomic, strong) UMComAllFeedViewController *recommendViewController;

@property (nonatomic, strong) UMComFilterTopicsViewController *filterTopicsViewController;

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UMComPageControlView *titlePageControl;

@property (nonatomic, strong) UIButton *findButton;

@end

@implementation UMComHomeFeedViewController
{
    BOOL  isTransitionFinish;
    CGRect leftDisAppearFrame;
    CGRect rightDisAppearFrame;
    CGRect currentViewFrame;
    CGPoint originOffset;
   
}

- (UMComSearchBar *)creatSearchBar
{
     UMComSearchBar *searchBar = [[UMComSearchBar alloc] initWithFrame:CGRectMake(0, -0.3, self.view.frame.size.width, 40)];
    searchBar.placeholder = UMComLocalizedString(@"Search user and content", @"搜索用户和内容");
    searchBar.delegate = self;
    return searchBar;
}
- (void)hidenKeyBoard
{
    [self.topicSearchBar resignFirstResponder];
}
- (void)creatNigationItemView
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.view.frame.size.width-34, self.navigationController.navigationBar.frame.size.height/2-11.5, 25, 25);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"find+"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(onClickFind:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightButton];
    self.findButton = rightButton;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
    if(self.navigationController.viewControllers.count > 1 || self.presentingViewController){
        [self.allFeedViewController.feedsTableView setViewController:self];
        [self.recommendViewController.feedsTableView setViewController:self];
        //是否显示返回按钮
        if(self.navigationController.viewControllers.count > 1 || self.presentingViewController){
            UMComBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose:)];
            [self.navigationItem setLeftBarButtonItems:@[leftButtonItem]];
        }else{
            UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            leftSpace.width = 85;
            [self.navigationItem setLeftBarButtonItems:@[leftSpace]];
        }
    }
    //创建菜单栏
    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(0, 0, 180, 25) itemTitles:[NSArray arrayWithObjects:UMComLocalizedString(@"focus", @"关注"),UMComLocalizedString(@"recommend",@"推荐"),UMComLocalizedString(@"topic",@"话题"), nil] currentPage:0];
    titlePageControl.currentPage = 0;
    titlePageControl.selectedColor = [UIColor whiteColor];
    titlePageControl.unselectedColor = [UIColor blackColor];
    [titlePageControl setItemImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"left_frame"],[UIImage imageNamed:@"midle_frame"],[UIImage imageNamed:@"right_item"], nil]];
    __weak UMComHomeFeedViewController *wealSelf = self;
    titlePageControl.didSelectedAtIndexBlock = ^(NSInteger index){
        [wealSelf transitionViewControllers:nil];
        [wealSelf hidenKeyBoard];
    };
    [self.navigationItem setTitleView:titlePageControl];
    self.titlePageControl = titlePageControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//<<<<<<< HEAD
//    UIBarButtonItem *topicButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"topic" target:self action:@selector(onClickTopic:)];
//    UIBarButtonItem *selfButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"find" target:self action:@selector(onClickFind:)];
//    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    space.width = 20;
//    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    rightSpace.width = 5;
//    [self.navigationItem setRightBarButtonItems:@[rightSpace,selfButtonItem,space,topicButtonItem]];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
//    
//    //创建控件
//    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, self.navigationController.navigationBar.frame.size.height)];
//    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    CGFloat titleHeight = titleView.frame.size.height/6*5;
//    titleButton.frame =CGRectMake(0,0, titleView.frame.size.width, titleHeight);
//    [titleButton setTitle:@"全部" forState:UIControlStateNormal];
//    titleButton.backgroundColor = [UIColor clearColor];
//    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [titleButton addTarget:self action:@selector(transitionViewControllers:) forControlEvents:UIControlEventTouchUpInside];
//    self.titleBt = titleButton;
//    
//    UMComPageControlView *titlePageControl = [[UMComPageControlView alloc]initWithFrame:CGRectMake(5, titleHeight-8, 30, 6) totalPages:2 currentPage:1];
//    titlePageControl.currentPage = 0;
//    [titleView addSubview:titleButton];
//    [titleView addSubview:titlePageControl];
//    self.titlePageControl = titlePageControl;
//    [self.navigationItem setTitleView:titleView];
//    
//    UISwipeGestureRecognizer *leftWwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(transitionViewControllers:)];
//    leftWwip.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:leftWwip];
//    
//    UISwipeGestureRecognizer *rightSwip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(transitionViewControllers:)];
//    rightSwip.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:rightSwip];
//    
//    self.recommendViewController = [[UMComAllFeedViewController alloc]init];
//    
//    [self.view addSubview:self.recommendViewController.view];
//    [self addChildViewController:self.recommendViewController];

    [self creatNigationItemView];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton.frame = CGRectMake(0, 0, 50, 50);
    [self.editButton setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
    [self.editButton setImage:[UIImage imageNamed:@"new+"] forState:UIControlStateSelected];
    [self.editButton addTarget:self action:@selector(onClickEdit:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow addSubview:self.editButton];
    //创建子ViewController
    
    self.allFeedViewController = [[UMComAllFeedViewController alloc]init];
    self.allFeedViewController.fetchFeedsController = [[UMComAllFeedsRequest alloc]initWithCount:BatchSize];
    [self.view addSubview:self.allFeedViewController.view];
    [self addChildViewController:self.allFeedViewController];
    self.tempfeedTableView = self.allFeedViewController.feedsTableView;
    self.currentViewController = self.allFeedViewController;
    
    self.recommendViewController = [[UMComAllFeedViewController alloc]init];
    [self.view addSubview:self.recommendViewController.view];
    rightDisAppearFrame = CGRectMake(2*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.recommendViewController.view.frame = rightDisAppearFrame;
    [self addChildViewController:self.recommendViewController];
    self.recommendViewController.feedsTableView.tableHeaderView = [self creatSearchBar];

    self.filterTopicsViewController = [[UMComFilterTopicsViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.view addSubview:self.filterTopicsViewController.view];
    self.filterTopicsViewController.view.frame = rightDisAppearFrame;
    [self addChildViewController:self.filterTopicsViewController];
    self.topicSearchBar = [self creatSearchBar];
    self.topicSearchBar.placeholder = UMComLocalizedString(@"Search topics", @"搜索话题");
    __weak UMComHomeFeedViewController *weakSelf = self;
    self.filterTopicsViewController.scrollViewScroll = ^(UIScrollView *scrollView){
        [weakSelf.topicSearchBar resignFirstResponder];
    };
    self.filterTopicsViewController.tableView.tableHeaderView = self.topicSearchBar;
    
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToLeftDirection:)];
    leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipToRightDirection:)];
    rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightGestureRecognizer];

    [self setEditButtonAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGSize selfViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    currentViewFrame = CGRectMake(0, 0, selfViewSize.width, selfViewSize.height);
    leftDisAppearFrame = CGRectMake(-selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
    rightDisAppearFrame = CGRectMake(selfViewSize.width, 0, selfViewSize.width, selfViewSize.height);
//    self.currentViewController.view.frame = CGRectMake(0, 0, selfViewSize.width, selfViewSize.height);
    [self resetAllViewControllerViewsSize:selfViewSize];
    if (self.allFeedViewController == self.currentViewController) {
        self.allFeedViewController.feedsTableView.tableHeaderView = [self creatSearchBar];
    }
    if (self.titlePageControl.currentPage == 2) {
        self.editButton.hidden = YES;
    }else{
        self.editButton.hidden = NO;
    }
    self.editButton.frame = CGRectMake(self.view.frame.size.width-DeltaRight - 25,[UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom -25, 50, 50);
    isTransitionFinish = YES;
    originOffset = self.navigationController.navigationBar.frame.origin;
    self.findButton.center = CGPointMake(selfViewSize.width-23.5, self.findButton.center.y);
    self.findButton.hidden = NO;
}

- (void)resetAllViewControllerViewsSize:(CGSize)size
{
    self.allFeedViewController.view.frame = CGRectMake(self.allFeedViewController.view.frame.origin.x, self.allFeedViewController.view.frame.origin.y, size.width, size.height);
    self.filterTopicsViewController.view.frame = CGRectMake(self.filterTopicsViewController.view.frame.origin.x, self.filterTopicsViewController.view.frame.origin.y, size.width, size.height);
    self.recommendViewController.view.frame = CGRectMake(self.recommendViewController.view.frame.origin.x, self.recommendViewController.view.frame.origin.y, size.width, size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.editButton.hidden = YES;
    self.findButton.hidden = YES;
    [self hidenKeyBoard];
}

#pragma mark - searchBarDelelagte

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (self.titlePageControl.currentPage != 2) {
        [[UMComSearchAction action] performActionAfterLogin:searchBar.text viewController:self completion:^(NSArray *data, NSError *error) {
        }];
        return NO;
    }else{
        self.editButton.hidden = YES;
        return YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    if (self.titlePageControl.currentPage == 2) {
         [self.filterTopicsViewController searchWhenClickAtSearchButtonResult:searchBar.text];
    }
    [self hidenKeyBoard];

}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.titlePageControl.currentPage == 2) {
        [self.filterTopicsViewController reloadTopicsDataWithSearchText:searchBar.text];
    }
}

- (void)swipToLeftDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage < 2) {
        self.titlePageControl.currentPage += 1;
        [self transitionViewControllers:nil];
    }
}

- (void)swipToRightDirection:(UISwipeGestureRecognizer *)swip
{
    if (self.titlePageControl.currentPage > 0) {
        self.titlePageControl.currentPage -= 1;
        [self transitionViewControllers:nil];
    }
}
- (void)transitionViewControllers:(id)sender
{
    if (!isTransitionFinish) {
        return;
    }
    UIViewController *temToViewController = nil;
    NSInteger currentPage = self.titlePageControl.currentPage;
    if (currentPage == 0) {
        self.editButton.hidden = NO;
        temToViewController = self.allFeedViewController;
        self.tempfeedTableView = self.allFeedViewController.feedsTableView;
    }else if (currentPage == 1){
        self.editButton.hidden = NO;
        self.tempfeedTableView = self.recommendViewController.feedsTableView;
        temToViewController = self.recommendViewController;
    }else if (currentPage == 2){
        self.editButton.hidden = YES;
        temToViewController = self.filterTopicsViewController;
    }
    if (self.currentViewController != temToViewController) {
        [self transitionToViewController:temToViewController];   
    }
}


- (void)transitionToViewController:(UIViewController *)toViewController
{
    [self transitionFromViewController:self.currentViewController toViewController:toViewController duration:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        isTransitionFinish = NO;
        if (toViewController == self.currentViewController) {
            return;
        }
        toViewController.view.frame = currentViewFrame;
        NSInteger currentPage = self.titlePageControl.currentPage;
        if (currentPage == 0) {
            self.recommendViewController.view.frame = rightDisAppearFrame;
            self.filterTopicsViewController.view.frame = rightDisAppearFrame;
        }else if (currentPage == 1){
            if (self.recommendViewController.fetchFeedsController == nil) {
                self.recommendViewController.fetchFeedsController = [[UMComRecommendFeedsRequest alloc]initWithCount:BatchSize];
                [self.recommendViewController refreshAllData];
            }
            self.allFeedViewController.view.frame = leftDisAppearFrame;
            self.filterTopicsViewController.view.frame = rightDisAppearFrame;
        }else if (currentPage == 2){
            if (self.filterTopicsViewController.allTopicsArray.count == 0) {
                [self.filterTopicsViewController reloadTopicsDataWithSearchText:nil];
            }
            self.recommendViewController.view.frame = leftDisAppearFrame;
            self.allFeedViewController.view.frame = leftDisAppearFrame;
        }
        [self setEditButtonAnimation];
    } completion:^(BOOL finished) {
        if (finished) {
            if ([toViewController isKindOfClass:[UMComAllFeedViewController class]]) {
                [self setEditButtonAnimation];
            }

            self.currentViewController = toViewController;
        }
        isTransitionFinish = YES;
    }];

}

- (void)setEditButtonAnimation
{
    self.editButton.center = CGPointMake(self.view.frame.size.width-DeltaRight, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
    __weak UMComHomeFeedViewController *weakSelf = self;
    self.tempfeedTableView.scrollViewDidScroll = ^(UIScrollView *scrollView, CGFloat lastPosition){
        
        if (scrollView.contentOffset.y >0 && scrollView.contentOffset.y > lastPosition+15) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                weakSelf.editButton.center = CGPointMake(weakSelf.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height+DeltaBottom);
            } completion:nil];
        }else{
            if (scrollView.contentOffset.y < lastPosition-15) {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    weakSelf.editButton.center = CGPointMake(weakSelf.editButton.center.x, [UIApplication sharedApplication].keyWindow.bounds.size.height-DeltaBottom);
                } completion:nil];
            }
        }
    };
}

-(IBAction)onClickClose:(id)sender
{
    if ([self.navigationController isKindOfClass:[UMComNavigationController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self.tempfeedTableView dismissAllEditView];
}

-(IBAction)onClickProfile:(id)sender
{
    [[UMComUserCenterAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
    }];
}

- (void)onClickFind:(UIButton *)sender
{
    [[UMComFindAction action] performActionAfterLogin:nil viewController:self completion:^(NSArray *data, NSError *error) {
    }];
}

-(IBAction)onClickTopic:(id)sender
{
    [[UMComTopicFilterAction action] performActionAfterLogin:nil viewController:self completion:nil];
}

-(IBAction)onClickEdit:(id)sender
{
    [[UMComEditAction action] performActionAfterLogin:nil viewController:self completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
