//
//  UMComEditViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComEditViewController.h"
#import "UMComLocationTableViewController.h"
#import "UMComFriendsTableViewController.h"
#import "UMImagePickerController.h"
#import "UMComEditTopicsViewController.h"
#import "UMComSyntaxHighlightTextStorage.h"
#import "UMComBarButtonItem.h"
#import "UMComFeedTableViewController.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComShowToast.h"
#import "UMUtils.h"
#import "UMComSession.h"
#import "UMComCollectionView.h"
#import "UIViewController+UMComAddition.h"
#import "UMComNavigationController.h"

#define ForwardViewHeight 101
#define EditToolViewHeight 43

#define textFont UMComFontNotoSansLightWithSafeSize(15)

#define MaxTextLength 300
#define MinTextLength 5

@interface UMComEditViewController ()
@property (nonatomic,strong) UMComEditTopicsViewController *topicsViewController;

@property (nonatomic, strong) UMComFeed *forwardFeed;       //转发的feed

@property (nonatomic, strong) UMComFeed *originFeed;        //转发的原始feed

@property (nonatomic, strong) UMComTopic *topic;

@property (nonatomic, strong) NSString *feedCreatedUsers;

@property (nonatomic, assign) CGFloat visibleViewHeight;

@property (nonatomic, assign) NSRange seletedRange;

@property (nonatomic, strong) NSMutableArray *originImages;

@property (nonatomic, strong) UMComSyntaxHighlightTextStorage *textStorage;

@property (nonatomic, strong) UITextView *forwardTextView;

@property (nonatomic, strong) UITextView *realTextView;

@property (nonatomic, strong) UMComCollectionView *emojiCollectionView;

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation UMComEditViewController
{
    UILabel *noticeLabel;
    BOOL    isShowTopicNoticeBgView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (id)init
{
    self = [[UMComEditViewController alloc] initWithNibName:@"UMComEditViewController" bundle:nil];
    return self;
}

-(id)initWithForwardFeed:(UMComFeed *)forwardFeed
{
    self = [[UMComEditViewController alloc] init];
    self.originFeed = forwardFeed;
    self.forwardFeed = forwardFeed;
    self.feedCreatedUsers = @"";
    while (self.originFeed.origin_feed) {
        self.feedCreatedUsers = [self.feedCreatedUsers stringByAppendingFormat:@"//@%@：%@ ",self.originFeed.creator.name,self.originFeed.text];
        self.originFeed = self.originFeed.origin_feed;
        
    }
    return self;
}

- (id)initWithTopic:(UMComTopic *)topic
{
    self = [[UMComEditViewController alloc] init];
    self.topic = topic;
    return self;
}

- (void)dealloc
{
    [self.editViewModel removeObserver:self forKeyPath:@"editContent"];
    [self.editViewModel removeObserver:self forKeyPath:@"locationDescription"];
}

-(void)viewWillAppear:(BOOL)animated
{
  
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
  
    self.editBgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.locationLabel setText:self.editViewModel.locationDescription];
    [self.realTextView becomeFirstResponder];
    self.realTextView.selectedRange = self.editViewModel.seletedRange;
     self.forwardImage.frame = CGRectMake(self.view.frame.size.width-92, 11, 70, 70);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    
    [self.realTextView resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowTopicNoticeBgView = YES;
    [self setTitleViewWithTitle:@"新鲜事"];
    UMComEditViewModel *editViewModel = [[UMComEditViewModel alloc] init];
    [editViewModel addObserver:self forkeyPath:@"editContent"];
    [editViewModel addObserver:self forkeyPath:@"locationDescription"];
    self.editViewModel = editViewModel;
    
    self.visibleViewHeight = 0;
    //创建textView
    if ([self isIos7AndLater]) {
        [self createTextViewios7];
    }else{
        [self createTextView];
    }
    
    //添加站位语句
    self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, -4.5, self.fakeTextView.frame.size.width-10, 40)];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    self.placeholderLabel.font = textFont;
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    [self.realTextView addSubview:self.placeholderLabel];
    
    if (self.originFeed) {
        self.placeholderLabel.text = @" 说说你的观点...";
        self.fakeForwardTextView.hidden = NO;
        [self.topicNoticeBgView removeFromSuperview];
        self.forwardImage = [[[UMComImageView imageViewClassName] alloc]initWithPlaceholderImage:[UIImage imageNamed:@""]];
        self.forwardImage.frame = CGRectMake(self.view.frame.size.width-92, 11, 70, 70);
        [self.forwardFeedBackground addSubview:self.forwardImage];
        NSString *showForwardText = [NSString stringWithFormat:@"@%@：%@", self.originFeed.creator.name? self.originFeed.creator.name:@"",self.originFeed.text?self.originFeed.text:@""];
        [self createForwardTextView:showForwardText];
        
        self.topicButton.hidden = YES;
        self.imagesButton.hidden = YES;
        self.takePhotoButton.hidden = YES;
        self.locationButton.hidden = YES;
        if (self.originFeed.images && [self.originFeed.images count] > 0) {
            self.forwardImage.hidden = NO;
            self.forwardImage.isAutoStart = YES;
            NSString *thumbnail = [[self.originFeed.images firstObject] valueForKey:@"360"];
            [self.forwardImage setImageURL:thumbnail placeHolderImage:[UIImage imageNamed:@"photox"]];
            
        }else{
            self.forwardImage.hidden = YES;
        }
        UIImage *resizableImage = [[UIImage imageNamed:@"origin_image_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.forwardFeedBackground.image = resizableImage;
    }else{
        self.placeholderLabel.text = @" 分享新鲜事...";
        self.topicNoticeBgView.frame = CGRectMake(20, 250, self.topicNoticeBgView.frame.size.width, 30);
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, self.topicNoticeBgView.frame.size.width, 25)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = textFont;
        label.textColor = [UIColor whiteColor];
        [self.topicNoticeBgView addSubview:label];
        if ([[[[UMComSession sharedInstance] loginUser] gender] integerValue] == 1) {
            label.text = @"大哥啊，添加个话题吧！";
        }else{
            label.text = @"大妹砸，添加个话题吧！";
        }

        self.fakeForwardTextView.hidden = YES;
        self.forwardImage.hidden = YES;
        [self setUpAddedImageView:nil];
        self.forwardFeedBackground.backgroundColor = [UIColor whiteColor];
        
        //加入话题列表
        self.topicsViewController = [[UMComEditTopicsViewController alloc] initWithEditViewModel:self.editViewModel];
        [self.topicsViewController.view setFrame:CGRectMake(0, self.editToolView.frame.origin.y+self.editToolView.bounds.size.height,self.view.bounds.size.width, self.view.bounds.size.height - self.editToolView.frame.origin.y-self.editToolView.bounds.size.height-self.locationBackgroundView.frame.size.height)];
        [self.editBgView addSubview:self.topicsViewController.view];
        
    }

    
    self.addedImageView.hidden = YES;
    self.locationBackgroundView.hidden = YES;
    self.forwardFeedBackground.hidden = NO;
    
    self.originImages = [NSMutableArray array];

    
    //设置导航条两端按钮
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"cancelx" target:self action:@selector(onClickClose:)];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];

    UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"sendx" target:self action:@selector(postContent)];
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    if (self.topic) {
        self.editViewModel.seletedRange = NSMakeRange(self.realTextView.text.length, 0);
    }
    if (self.originFeed) {
        self.editViewModel.seletedRange = NSMakeRange(0, 0);
    }
    self.forwardFeedBackground.hidden = YES;
    self.editToolView.hidden = YES;

    [self showPlaceHolderLabelWithTextView:self.realTextView];
}

- (BOOL)isIos7AndLater
{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 7.0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"editContent"])
    {
        [self.realTextView setText:self.editViewModel.editContent];
        NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc]initWithString:self.editViewModel.editContent];
        [self creatHighLightForAttributedString:attributString font:textFont];
        isShowTopicNoticeBgView = NO;
        self.realTextView.attributedText = attributString;
        self.realTextView.font = textFont;
        self.realTextView.selectedRange = self.editViewModel.seletedRange;
        
        [self.realTextView becomeFirstResponder];
    }
    if ([keyPath isEqualToString:@"locationDescription"]) {
        [self.locationLabel setText:self.editViewModel.locationDescription];
        self.locationBackgroundView.hidden = NO;
        [self viewsFrameChange];
        [self.realTextView becomeFirstResponder];
    }
}

/*****************************ios7and later start************************************/


- (void)createTextViewios7
{
    NSDictionary* attrs = @{NSFontAttributeName:
                                textFont};
    NSAttributedString* attrString = [[NSAttributedString alloc]
                                      initWithString:self.editViewModel.editContent
                                      attributes:attrs];
    UMComSyntaxHighlightTextStorage *textStorage = [UMComSyntaxHighlightTextStorage new];
    [textStorage appendAttributedString:attrString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.view.frame.size.width, 120)];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [textStorage addLayoutManager:layoutManager];
    
    self.realTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.editBgView.frame.size.width, 120) textContainer:container];
    [self.realTextView setFont:textFont];
    [self.view addSubview:self.realTextView];
    [textStorage update];
        self.realTextView.delegate = self;
    self.realTextView.editable = YES;
    self.realTextView.userInteractionEnabled = YES;
    self.fakeTextView.hidden = YES;
    //如果有话题则默认添加话题
    if (self.topic && [UMComSession sharedInstance].isShowTopicName) {
        [self.realTextView setText:[NSString stringWithFormat:@"#%@#",self.topic.name]];
    }
    self.fakeTextView.editable = NO;
    if (self.originFeed) {
        self.realTextView.text = self.feedCreatedUsers;
    }
    
    __weak UMComEditViewController *weakSelf = self;
    
    textStorage.updateBlock = ^(NSArray *matches,NSString *key){
        if ([key isEqualToString:TopicRulerString]) {
            if (matches.count == 0) {
                weakSelf.topicNoticeBgView.hidden = NO;
                isShowTopicNoticeBgView = YES;
            }else{
                weakSelf.topicNoticeBgView.hidden = YES;
                isShowTopicNoticeBgView = NO;
            }
            [weakSelf viewsFrameChange];
            
            
            for (UMComTopic* topic in self.editViewModel.topics) {
                BOOL match = NO;
                for (NSTextCheckingResult *result in matches) {
                    NSRange topicRange = NSMakeRange(result.range.location + 1, result.range.length -2);
                    NSString *resultString = [self.realTextView.text substringWithRange:topicRange];
                    
                    if ([resultString isEqualToString:topic.name]) {
                        match = YES;
                        break;
                    }
                }
                if (!match) {
                    [self.editViewModel.topics removeObject:topic];
                }
            }
        } else {
            for (UMComUser *follower in self.editViewModel.followers) {
                BOOL match = NO;
                for (NSTextCheckingResult *result in matches) {
                    NSRange userRange = NSMakeRange(result.range.location + 1, result.range.length -1);
                    NSString *resultString = [self.realTextView.text substringWithRange:userRange];
                    if ([resultString isEqualToString:follower.name]) {
                        match = YES;
                        break;
                    }
                }
                if (!match) {
                    [self.editViewModel.followers removeObject:follower];
                }
            }
        }
    };
    self.textStorage = textStorage;
}


/*****************************ios7and later end************************************/


- (void)createForwardTextView:(NSString *)forwardString
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSDictionary* attrs = @{NSFontAttributeName:
                                textFont,NSParagraphStyleAttributeName:paragraphStyle};
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]
                                      initWithString:forwardString
                                      attributes:attrs];
    self.fakeForwardTextView.textAlignment = NSTextAlignmentCenter;
    self.fakeForwardTextView.font = textFont;
    [self creatHighLightForAttributedString:attrString font:textFont];
    [self.fakeForwardTextView setAttributedText:attrString];
    self.fakeForwardTextView.editable = NO;
}

- (void)createTextView
{
    self.realTextView = self.fakeTextView;
    //如果有话题则默认添加话题
    if (self.topic) {
        [self.realTextView setText:[NSString stringWithFormat:@"#%@#",self.topic.name]];
    }
    if (self.originFeed) {
        self.realTextView.text = self.feedCreatedUsers;
    }
    self.realTextView.textColor = [UIColor blackColor];
    NSString *text = self.realTextView.text;
    if (text.length == 0) {
        text = @" ";
    }
    NSDictionary* attrs = @{NSFontAttributeName:
                                textFont};
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc]
                                             initWithString:text
                                             attributes:attrs];
    [self creatHighLightForAttributedString:attrString font:textFont];
    self.realTextView.attributedText = attrString;
    [self.realTextView setFont:textFont];
    self.realTextView.delegate = self;

    self.realTextView.frame = CGRectMake(0, 0, self.editBgView.frame.size.width, 80);
}


- (void)setUpAddedImageView:(NSArray *)images
{
    if(!self.addedImageView)
    {
        __weak typeof(self) weakSelf = self;
        self.addedImageView = [[UMComAddedImageView alloc] initWithUIImages:nil screenWidth:self.forwardFeedBackground.frame.size.width];
        self.addedImageView.backgroundColor = [UIColor whiteColor];
        [self.addedImageView setPickerAction:^{
            [weakSelf setUpPicker];
        }];
        self.addedImageView.imagesChangeFinish = ^(){
            [weakSelf viewsFrameChange];
            [weakSelf.realTextView becomeFirstResponder];
        };
        
        self.addedImageView.imagesDeleteFinish = ^(NSInteger index){
            [weakSelf.originImages removeObjectAtIndex:index];
            [weakSelf.realTextView becomeFirstResponder];
        };
        
        [self.addedImageView addImages:images];
        self.addedImageView.actionWithTapImages = ^(){
            [weakSelf viewsFrameChange];
            [weakSelf.realTextView becomeFirstResponder];
        };

        [self.forwardFeedBackground addSubview:self.addedImageView];
    }
    else
    {
        [self.addedImageView setScreemWidth:self.forwardFeedBackground.frame.size.width];
        [self.addedImageView addImages:images];
    }
    if (self.locationLabel.text.length > 0) {
        [self.addedImageView setOrign:CGPointMake(0,self.locationBackgroundView.frame.size.height)];
        self.addedImageView.frame = CGRectMake(0, self.locationBackgroundView.frame.size.height, self.forwardFeedBackground.frame.size.width, 70);
    }else{
        [self.addedImageView setOrign:CGPointMake(0,0)];
            self.addedImageView.frame = CGRectMake(0, 0, self.forwardFeedBackground.frame.size.width, 70);
    }
    self.addedImageView.contentSize = CGSizeMake(self.forwardFeedBackground.frame.size.width, self.addedImageView.contentSize.height);
    self.addedImageView.hidden = NO;
}


- (void)viewsFrameChange
{
    CGFloat visibleHeight = self.visibleViewHeight;
    if (visibleHeight == 0) {
        visibleHeight  = self.editBgView.frame.size.height*4/9;
    }
    CGFloat forwordViewHeight = 5;
    CGFloat deltaHeight = 0;
    if (self.originFeed) {
        forwordViewHeight = self.forwardFeedBackground.frame.size.height;
        if (!self.originFeed.images || [self.originFeed.images count] == 0) {
            self.fakeForwardTextView.frame = CGRectMake(self.fakeForwardTextView.frame.origin.x, self.fakeForwardTextView.frame.origin.y, self.forwardFeedBackground.frame.size.width, self.fakeForwardTextView.frame.size.height);
        }
        self.atFriendButton.center = CGPointMake(self.editBgView.frame.size.width/4, self.editToolView.frame.size.height/2);
        self.emojiButton.center = CGPointMake(self.editBgView.frame.size.width/4*3, self.editToolView.frame.size.height/2);

    }else{
        if (self.addedImageView.arrayImages.count == 0 || !self.addedImageView) {
            self.addedImageView.hidden = YES;

        }else{
            CGFloat locationViewHeight = 0;
            if (self.locationLabel.text.length > 0) {
                locationViewHeight = self.locationBackgroundView.frame.size.height;
                self.locationBackgroundView.frame = CGRectMake(0, 0, self.forwardFeedBackground.frame.size.width, locationViewHeight);
                [self.addedImageView setOrign:CGPointMake(0, locationViewHeight)];
            }else{
                locationViewHeight = 0;
                [self.addedImageView setOrign:CGPointMake(0,0)];
            }
            self.addedImageView.frame = CGRectMake(0,locationViewHeight, self.addedImageView.frame.size.width, self.addedImageView.frame.size.height);
            self.addedImageView.contentSize = CGSizeMake(self.addedImageView.frame.size.width, self.addedImageView.contentSize.height);
            self.addedImageView.hidden = NO;
            forwordViewHeight += self.addedImageView.frame.size.height;
        }
        if (self.locationLabel.text.length > 0) {
            self.locationLabel.hidden = NO;
            forwordViewHeight += self.locationBackgroundView.frame.size.height;
        }else{
            self.locationBackgroundView.hidden = YES;
        }
        CGFloat viewSpace = (self.editToolView.frame.size.width - 48*6)/7;
        self.topicButton.center = CGPointMake((24+viewSpace), self.editToolView.frame.size.height/2);
        self.takePhotoButton.center = CGPointMake(self.topicButton.center.x+48+viewSpace, self.editToolView.frame.size.height/2);
        self.imagesButton.center = CGPointMake(self.takePhotoButton.center.x+48+viewSpace, self.editToolView.frame.size.height/2);
        self.locationButton.center = CGPointMake(self.imagesButton.center.x+48+viewSpace, self.editToolView.frame.size.height/2);
        self.atFriendButton.center = CGPointMake(self.locationButton.center.x+48+viewSpace, self.editToolView.frame.size.height/2);
        self.emojiButton.center = CGPointMake(self.atFriendButton.center.x+48+viewSpace, self.editToolView.frame.size.height/2);
        self.topicNoticeBgView.frame = CGRectMake(self.topicButton.center.x, self.editToolView.frame.origin.y-30, self.topicNoticeBgView.frame.size.width, 30);
        [self.editBgView bringSubviewToFront:self.topicNoticeBgView];
        if (isShowTopicNoticeBgView == YES && self.topic == nil) {
            if (self.addedImageView.arrayImages.count == 0) {
                deltaHeight = 30;   
            }
            self.topicNoticeBgView.hidden = NO;
            
        }else{
            self.topicNoticeBgView.hidden = YES;
        }
    }
    self.realTextView.frame = CGRectMake(0, 0, self.editBgView.frame.size.width,visibleHeight-forwordViewHeight-5-deltaHeight);
    self.forwardFeedBackground.frame = CGRectMake(self.forwardFeedBackground.frame.origin.x, self.realTextView.frame.size.height+2, self.forwardFeedBackground.frame.size.width,forwordViewHeight);
    if (self.locationLabel.text.length > 0 && [self.addedImageView.arrayImages count] > 0) {
        self.locationBackgroundView.frame = CGRectMake(self.addedImageView.frame.origin.x+self.addedImageView.imageSpace-8, self.locationBackgroundView.frame.origin.y, self.locationBackgroundView.frame.size.width, self.locationBackgroundView.frame.size.height);
    }
}

-(void)keyboardWillShow:(NSNotification*)notification
{
   CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    self.editToolView.hidden = NO;
    self.visibleViewHeight = self.editBgView.frame.size.height - endheight - self.editToolView.frame.size.height;
    self.editToolView.frame = CGRectMake(self.editToolView.frame.origin.x,self.visibleViewHeight, keybordFrame.size.width, self.editToolView.frame.size.height);
    [self viewsFrameChange];
    self.topicsViewController.view.frame = CGRectMake(0,self.editBgView.frame.size.height-endheight, self.editBgView.frame.size.width, endheight);
    [self.editBgView updateConstraints];
    self.editToolView.hidden = NO;
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    self.visibleViewHeight = self.editBgView.frame.size.height - endheight - self.editToolView.frame.size.height;
    self.editToolView.frame = CGRectMake(self.editToolView.frame.origin.x,self.visibleViewHeight, keybordFrame.size.width, self.editToolView.frame.size.height);
    self.editToolView.hidden = NO;
    [self viewsFrameChange];
    self.topicsViewController.view.frame  = CGRectMake(0,self.editToolView.frame.origin.y+self.editToolView.frame.size.height, self.editBgView.frame.size.width, endheight);
    [self.topicsViewController.tableView setContentInset:UIEdgeInsetsZero];
    self.forwardFeedBackground.hidden = NO;
}

-(void)onClickClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(IBAction)showTopicPicker:(id)sender
{
    [self.editBgView bringSubviewToFront:self.topicsViewController.view];
    self.topicsViewController.view.hidden = NO;
    self.emojiCollectionView.hidden = YES;
    self.editViewModel.seletedRange = self.seletedRange;
    if ([self.realTextView isFirstResponder]) {
        [self.realTextView resignFirstResponder];
    } else {
        [self.realTextView becomeFirstResponder];
    }
}


-(IBAction)showImagePicker:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Too many images",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return;
    }
    [self setUpPicker];
}

-(IBAction)takePhoto:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Too many images",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}
- (IBAction)showEmojis:(id)sender {
    if (!self.emojiCollectionView) {
        //创建表情列表视图
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        self.emojiCollectionView = [[UMComCollectionView alloc]initWithFrame:CGRectMake(0, self.editToolView.frame.origin.y+self.editToolView.bounds.size.height,self.view.bounds.size.width, self.view.bounds.size.height - self.editToolView.frame.origin.y-self.editToolView.bounds.size.height-self.locationBackgroundView.frame.size.height) collectionViewLayout:layout];
        __weak UMComEditViewController *weakSelf = self;
        self.emojiCollectionView.didSelectedAtImage = ^(NSString *imageName){
            NSMutableString *temString = [[NSMutableString alloc]initWithString:weakSelf.realTextView.text];
            [temString insertString:imageName atIndex:weakSelf.realTextView.selectedRange.location];
            weakSelf.realTextView.text = temString;
            if ([weakSelf isIos7AndLater]) {
                [weakSelf.textStorage update];
            }
        };
        [self.view addSubview:self.emojiCollectionView];
    }
    self.topicsViewController.view.hidden = YES;
    self.emojiCollectionView.hidden = NO;
    [self.editBgView bringSubviewToFront:self.emojiCollectionView];
    self.editViewModel.seletedRange = self.seletedRange;
    if ([self.realTextView isFirstResponder]) {
        [self.realTextView resignFirstResponder];
    } else {
        [self.realTextView becomeFirstResponder];
    }}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *tempIamge = nil;
    if (selectImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(selectImage.size);
        [selectImage drawInRect:CGRectMake(0, 0, selectImage.size.width, selectImage.size.height)];
        tempIamge = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        tempIamge = selectImage;
    }
    if (self.originImages.count < 9) {
        [self.originImages addObject:tempIamge];
        [self setUpAddedImageView:@[tempIamge]];
    }
}

- (void)setUpPicker
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问照片的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        return;
    }
    if([UMImagePickerController isAccessible])
    {
        UMImagePickerController *imagePickerController = [[UMImagePickerController alloc] init];
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 9 - [self.addedImageView.arrayImages count];
        
        [imagePickerController setFinishHandle:^(BOOL isCanceled,NSArray *assets){
            if(isCanceled)
            {
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSMutableArray *array = [NSMutableArray array];
                    for(ALAsset *asset in assets)
                    {
                        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                        if (image) {
                            [array addObject:image];
                        }
                        if ([asset defaultRepresentation]) {
                            UIImage *originImage = [UIImage
                                                    imageWithCGImage:[asset.defaultRepresentation fullScreenImage]
                                                    scale:[asset.defaultRepresentation scale]
                                                    orientation:UIImageOrientationUp];
                            if (originImage) {
                                [self.originImages addObject:originImage];
                            }
                        } else {
                            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                            image = [self compressImage:image];
                            if (image) {
                                [self.originImages addObject:image];
                            }
                        }
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setUpAddedImageView:array];
                    });
                });
                
            }
        }];
        
        UMComNavigationController *navigationController = [[UMComNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

- (UIImage *)compressImage:(UIImage *)image
{
    UIImage *resultImage  = image;
    if (resultImage.CGImage) {
        NSData *tempImageData = UIImageJPEGRepresentation(resultImage,0.9);
        if (tempImageData) {
            resultImage = [UIImage imageWithData:tempImageData];
        }
    }
    return resultImage;
}

-(IBAction)showAtFriend:(id)sender
{
    self.editViewModel.seletedRange = self.seletedRange;
    UMComFriendsTableViewController *friendViewController = [[UMComFriendsTableViewController alloc] initWithEditViewModel:self.editViewModel];
    [self.navigationController pushViewController:friendViewController animated:YES];
}

#pragma mark UITextView
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    self.seletedRange = textView.selectedRange;
    [self showPlaceHolderLabelWithTextView:textView];

}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.editViewModel.editContent setString:textView.text];
    if ([self isIos7AndLater]) {
        [self.textStorage update];
    }
    [self showPlaceHolderLabelWithTextView:textView];
}


- (void)showPlaceHolderLabelWithTextView:(UITextView *)textView
{
    if (textView.text.length > 0 && ![@" " isEqualToString:textView.text]) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }
    self.editViewModel.seletedRange = textView.selectedRange;
    if (textView == self.realTextView) {
        [self.editViewModel.editContent setString:textView.text];
        NSMutableAttributedString *mutiAttributString = [[NSMutableAttributedString alloc]initWithString:textView.text];
        [self creatHighLightForAttributedString:mutiAttributString font:textFont];
        textView.attributedText = mutiAttributString;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"@" isEqualToString:text]) {
        [self showAtFriend:nil];
        return YES;
    }
    if ([@"#" isEqualToString:text]) {
        if (self.originFeed == nil) {
            NSInteger location = textView.selectedRange.location;
            NSMutableString *tempString = [NSMutableString stringWithString:textView.text];
            [tempString insertString:@"#" atIndex:textView.selectedRange.location];
            textView.text = tempString;
            textView.selectedRange = NSMakeRange(location+1, 0);
            [textView resignFirstResponder];
            return YES;
        }
    }
    if (textView.text.length >=300 && text.length > 0) {
        noticeLabel = [[UILabel alloc]initWithFrame:textView.frame];
        noticeLabel.backgroundColor = [UIColor clearColor];
        [textView.superview addSubview:noticeLabel];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.textColor = [UIColor grayColor];
        noticeLabel.hidden = NO;
        text = @"";
        [self performSelector:@selector(hiddenTextView) withObject:nil afterDelay:0.8f];
        return NO;
    }
    return YES;
}


//产生高亮字体
- (void)creatHighLightForAttributedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font
{
    if (attributedString.length == 0) {
        return;
    }
    [attributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor blackColor] range:NSMakeRange(0, attributedString.length-1)];

    NSString *string = attributedString.string;
    NSError *error = nil;
    UIColor *blueColor = [UMComTools colorWithHexString:FontColorBlue];
    NSString *regulaStr = TopicRulerString;//\\u4e00-\\u9fa5_a-zA-Z0-9//@"(#([^#]+)#)"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [regex matchesInString:string
                                                    options:0
                                                      range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
            [attributedString addAttribute:(id)NSForegroundColorAttributeName value:(id)blueColor range:match.range];
        }
    }
    
    NSString *userNameRegulaStr = UserRulerString;//@"(@[\\u4e00-\\u9fa5_a-zA-Z0-9]+)";
    NSRegularExpression *userNameRegex = [NSRegularExpression regularExpressionWithPattern:userNameRegulaStr
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
    if (error == nil)
    {
        NSArray *arrayOfAllMatches = [userNameRegex matchesInString:string
                                                            options:0
                                                              range:NSMakeRange(0, [string length])];
        for (NSTextCheckingResult *match in arrayOfAllMatches)
        {
             [attributedString addAttribute:(id)NSForegroundColorAttributeName value:(id)blueColor range:match.range];
        }
    }
    [attributedString addAttribute:NSFontAttributeName value:(id)font range:NSMakeRange(0, attributedString.length)];
 
}


- (void)hiddenTextView
{
    self.editToolView.hidden = NO;
    noticeLabel.hidden = YES;
}


-(IBAction)showLocationPicker:(id)sender
{
    UMComLocationTableViewController *locationViewController = [[UMComLocationTableViewController alloc] initWithEditViewModel:self.editViewModel];
    [self.navigationController pushViewController:locationViewController animated:YES];
}


- (UIImage *)fixOrientation:(UIImage *)sourceImage
{
    // No-op if the orientation is already correct
    if (sourceImage.imageOrientation == UIImageOrientationUp) return sourceImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (sourceImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, sourceImage.size.width, sourceImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, sourceImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, sourceImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:;
    }
    
    switch (sourceImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, sourceImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, sourceImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, sourceImage.size.width, sourceImage.size.height,
                                             CGImageGetBitsPerComponent(sourceImage.CGImage), 0,
                                             CGImageGetColorSpace(sourceImage.CGImage),
                                             CGImageGetBitmapInfo(sourceImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (sourceImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,sourceImage.size.height,sourceImage.size.width), sourceImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,sourceImage.size.width,sourceImage.size.height), sourceImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (BOOL)isString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length > 0) {
        return YES;
    }
    return NO;
}

- (void)postContent
{
    [self.realTextView resignFirstResponder];
    [self.editViewModel.editContent setString:self.realTextView.text];
    if (!self.forwardFeed && ![self isString:self.realTextView.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"消息不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        
        return;
    }
    
    NSInteger topicAndUserLength = 0;
    for (UMComTopic *topic in self.editViewModel.topics) {
        topicAndUserLength += topic.name.length + 2;
    }
    for (UMComUser *user in self.editViewModel.followers) {
        topicAndUserLength += user.name.length +2;
    }
    
    NSString *realTextString = [self.realTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableString *realString = [NSMutableString stringWithString:realTextString];
    if (self.topic) {
        //若需要显示话题用户手动删除话题就不带话题id，如果不需要显示话题就自动加上话题id
        NSString *topicName = [NSString stringWithFormat:@"#%@#",self.topic.name];
        NSRange range = [self.editViewModel.editContent rangeOfString:topicName];
        if (range.length > 0 && [UMComSession sharedInstance].isShowTopicName) {
            [realString replaceCharactersInRange:range withString:@""];
        }
    }
    if (self.forwardFeed == nil && realString.length - topicAndUserLength < MinTextLength) {
        
        NSString *tooShortNotice = [NSString stringWithFormat:@"发布的内容太少啦，再多写点内容。"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooShortNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        return;
    }
    
    if (self.realTextView.text && self.realTextView.text.length > MaxTextLength) {
        NSString *tooLongNotice = [NSString stringWithFormat:@"内容过长,超出%d个字符",(int)self.realTextView.text.length - MaxTextLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooLongNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.fakeForwardTextView.hidden) {
        if (self.topic) {
            //若需要显示话题用户手动删除话题就不带话题id，如果不需要显示话题就自动加上话题id
            NSString *topicName = [NSString stringWithFormat:@"#%@#",self.topic.name];
            NSRange range = [self.editViewModel.editContent rangeOfString:topicName];
            if (range.length > 0 || ![UMComSession sharedInstance].isShowTopicName) {
                [self.editViewModel.topics addObject:self.topic];
            }
        }
        NSMutableArray *postImages = [NSMutableArray array];
        //                        //iCloud共享相册中的图片没有原图
        for (UIImage *image in self.originImages) {
            UIImage *originImage = [self compressImage:image];
            [postImages addObject:originImage];
        }
        
        
        [self.editViewModel postEditContentWithImages:postImages response:^(id responseObject, NSError *error) {
            if (error) {
                [UMComShowToast createFeedFail:error];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:error];
            }else if(responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if ([responseObject valueForKey:@"err_code"]) {
                    [UMComShowToast dealWithFeedFailWithErrorCode:[[responseObject valueForKey:@"err_code"] integerValue]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:responseObject];
                }else{
                    [UMComShowToast createFeedSuccess];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:nil];
                }
            }else{
                [UMComShowToast createFeedSuccess];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:nil];
            }
            
        }];
    } else {
        [self.editViewModel postForwardFeed:self.forwardFeed response:^(id responseObject, NSError *error) {
            if (error) {
                [UMComShowToast createFeedFail:error];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:error];
            } else if(responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if ([responseObject valueForKey:@"err_code"]) {
                    [UMComShowToast dealWithFeedFailWithErrorCode:[[responseObject valueForKey:@"err_code"] integerValue]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:responseObject];
                }else{
                    [UMComShowToast createFeedSuccess];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:nil];
                }
            }else{
                [UMComShowToast createFeedSuccess];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResult object:nil];
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
