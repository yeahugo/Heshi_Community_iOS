//
//  UMComProfileSettingController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/27.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComProfileSettingController.h"
#import "UMComBarButtonItem.h"
#import "UMImageView.h"
#import "UMComGenderView.h"
#import "UMComPullRequest.h"
#import "UMComUser.h"
#import "UMComHttpManager.h"
#import "UMComSession.h"
#import "UMComCoreData.h"
#import "UMComShowToast.h"
#import "UMUtils.h"

#define NoticeLabelTag 10001

@interface UMComProfileSettingController ()
@property (weak, nonatomic) IBOutlet UMImageView *userImage;
//@property (weak, nonatomic) IBOutlet UILabel *gender;

@property (strong, nonatomic) UMComUserProfile *profile;

@property (nonatomic, strong) UMComUser *user;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, strong) UMComPullRequest *fetchUserProfileController;

@end

@implementation UMComProfileSettingController
{
    UILabel *noticeLabel;
}

//- (id)initWithProfile:(UMComUserProfile *)profile
//{
//    self = [super initWithNibName:@"UMComProfileSettingController" bundle:nil];
//    if(self){
//        
//        self.user = [UMComSession sharedInstance].loginUser.user;
//        self.profile =[UMComSession sharedInstance].profile;
//        //        [self setUserProfile:profile];视图未创建
//        
//    }
//    return self;
//}

- (id)initWithUid:(NSString *)uid
{
    self = [super initWithNibName:@"UMComProfileSettingController" bundle:nil];
    if (self) {
        //        self.user = user;
        //       设置页面只有登录用户才能访问
        self.uid = uid;
//        self.profile = [UMComSession sharedInstance].profile;
        self.user = [UMComSession sharedInstance].loginUser;
    }
    return self;
}

//- (id)initWithUser:(UMComUser *)user
//{
//    self = [super initWithNibName:@"UMComProfileSettingController" bundle:nil];
//    if (self) {
//        //        self.user = user;
//        //       设置页面只有登录用户才能访问
//        self.user = [UMComSession sharedInstance].loginUser.user;
//        self.profile = [UMComSession sharedInstance].profile;
//    }
//    return self;
//}



-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.registerError) {
        [UMComShowToast registerError:self.registerError];
    }
    self.portraitImageView.clipsToBounds = YES;
    self.portraitImageView.layer.cornerRadius = self.portraitImageView.frame.size.width/2;
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.nameField.delegate = self;
    int gender = [[UMComSession sharedInstance].loginUser.gender intValue];
    [self.genderPicker selectRow:gender inComponent:0 animated:NO];
    
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"Backx" target:self action:@selector(onClickClose)];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    
    UIBarButtonItem *saveButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"Save",@"保存") target:self action:@selector(onClickSave)];
    saveButtonItem.customView.frame = CGRectMake(0, 0, 40, 35);
    self.navigationItem.rightBarButtonItem = saveButtonItem;
//    [self.navigationItem setRightBarButtonItems:@[saveButtonItem]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont:UMComFontNotoSansDemiWithSafeSize(18)}];
    [self.navigationItem setTitle:UMComLocalizedString(@"ProfileSetting", @"帐号设置")];
    
    UITapGestureRecognizer *userImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickChangeUserImage)];
    [self.userImage addGestureRecognizer:userImageGesture];
    
    [self.genderButton addTarget:self action:@selector(onClickChangeGender) forControlEvents:UIControlEventTouchUpInside];
 
    if ([UMComSession sharedInstance].loginUser) {
        [self setUserProfile:nil];
    } else {
        [self setUserProfile];
        UMComUserProfileRequest *userProfileController = [[UMComUserProfileRequest alloc] initWithUid:[UMComSession sharedInstance].uid];
        [userProfileController fetchRequestFromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
            if (!error) {
                if (data && data.count > 0) {
                    [UMComSession sharedInstance].loginUser = data.firstObject;
                    self.profile = data.firstObject;
                    
                    [self setUserProfile:nil];
                }
            } else {
                UMLog(@"fetch user profile fail");
            }
        }];
    }
    
    if (self.registerError) {
        self.nameField.text = [UMComSession sharedInstance].currentUserAccount.name;
        [self setGender:[[UMComSession sharedInstance].currentUserAccount.gender integerValue]];
        [self.userImage setImageURL:[NSURL URLWithString:[UMComSession sharedInstance].currentUserAccount.icon_url]];
    }
    
    self.topLineView.backgroundColor = [UMComTools colorWithHexString:TableViewSeparatorColor];
    self.topLineView.frame = CGRectMake(0, self.topLineView.frame.origin.y, self.view.frame.size.width, BottomLineHeight);
    
    self.mindleLineView.backgroundColor = [UMComTools colorWithHexString:TableViewSeparatorColor];
    self.mindleLineView.frame = CGRectMake(0, self.mindleLineView.frame.origin.y, self.view.frame.size.width, BottomLineHeight);
    
    self.bottomLineView.backgroundColor = [UMComTools colorWithHexString:TableViewSeparatorColor];
    self.bottomLineView.frame = CGRectMake(0, self.bottomLineView.frame.origin.y, self.view.frame.size.width, BottomLineHeight);
//    [self.fetchUserProfileController executeFetchRequestWithCompletion:^(NSArray *data, NSError *error) {
//        if (!error) {
//            [self setUserProfile:self.user.user_profile];
//        }
//    }];
}

- (void)setGender:(NSInteger)gender
{
    if (gender == 0) {
        [self.genderButton setTitle:UMComLocalizedString(@"Female",@"女") forState:UIControlStateNormal];
    } else {
        [self.genderButton setTitle:UMComLocalizedString(@"Male",@"男") forState:UIControlStateNormal];
    }
}

- (void)onClickChangeUserImage
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
//        [UIView setAnimationsEnabled:YES];  
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
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

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (selectImage) {
        selectImage = [self fixOrientation:selectImage];
        [self.userImage setImage:selectImage];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [UMComHttpManager updateProfileImage:selectImage response:^(id responseObject, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateUserProfileSuccess object:self];
        }];
    }
}

- (void)setUserProfile
{
    [self.nameField setText:self.user.name];
    if (self.user.icon_url) {
        [self.userImage  setImageURL:[NSURL URLWithString:[self.user.icon_url valueForKey:@"240"]]];
    }
    
    [self setGender:self.user.gender.integerValue];
    
    //fix #324 by djx
    if ([UMComSession sharedInstance].loginUser &&[[UMComSession sharedInstance].loginUser.gender intValue] == 0) {
        [self.genderButton setTitle:UMComLocalizedString(@"Female",@"女") forState:UIControlStateNormal];
    } else {
        [self.genderButton setTitle:UMComLocalizedString(@"Male",@"男") forState:UIControlStateNormal];
    }
}

- (void)setUserProfile:(UMComUser *)profile
{
    if ([self.user.gender intValue] == 0) {
        [self.userImage setPlaceholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [self.userImage setPlaceholderImage:[UIImage imageNamed:@"male"]];
    }
    if (self.user.icon_url) {
        [self.userImage  setImageURL:[NSURL URLWithString:[self.user.icon_url valueForKey:@"240"]]];
    }
    [self.nameField setText:self.user.name];
    if ([UMComSession sharedInstance].loginUser && [[UMComSession sharedInstance].loginUser.gender integerValue] == 0) {
        [self.genderButton setTitle:UMComLocalizedString(@"Female",@"女") forState:UIControlStateNormal];
    } else {
        [self.genderButton setTitle:UMComLocalizedString(@"Male",@"男") forState:UIControlStateNormal];
    }

}


- (void)onClickChangeGender
{
    [self.nameField resignFirstResponder];
    NSLog(@"click change gender!");
    self.genderPicker.hidden = NO;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (row == 0) {
        [self.genderButton setTitle:UMComLocalizedString(@"Female",@"女") forState:UIControlStateNormal];
    } else {
        [self.genderButton setTitle:UMComLocalizedString(@"Male",@"男") forState:UIControlStateNormal];
    }
    self.genderPicker.hidden = YES;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    if (row == 1) {
        title = UMComLocalizedString(@"Male",@"男");
    }
    if (row == 0) {
        title = UMComLocalizedString(@"FeMale",@"女");
    }
    return title;
}


-(void)onClickClose
{
//    [UIView setAnimationsEnabled:YES];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.completion) {
                self.completion(nil,nil);
            }
        }];
    }
}

-(void)onClickSave
{
    
    [self.nameField resignFirstResponder];
    if (self.nameField.text.length < 2) {
        [[[UIAlertView alloc]initWithTitle:UMComLocalizedString(@"sorry", @"抱歉") message:UMComLocalizedString(@"The user nickname is too short", @"用户昵称太短了") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK", @"好的") otherButtonTitles:nil, nil] show];
        return;
    }
    if (self.nameField.text.length > 20) {
        [[[UIAlertView alloc]initWithTitle:UMComLocalizedString(@"sorry", @"抱歉") message:UMComLocalizedString(@"The user nickname is too long", @"用户昵称过长") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK", @"好的") otherButtonTitles:nil, nil] show];
        return;
    }
    if ([self isIncludeSpecialCharact:self.nameField.text]) {
        [[[UIAlertView alloc]initWithTitle:UMComLocalizedString(@"sorry", @"抱歉") message:UMComLocalizedString(@"The input character does not conform to the requirements", @"昵称只能包含中文、中英文字母、数字和下划线") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK", @"好的") otherButtonTitles:nil, nil] show];
        return;
    }
    
    UMComUserAccount *userAccount = [[UMComUserAccount alloc]init];
    userAccount.name = self.nameField.text;
    userAccount.gender = [NSNumber numberWithInteger:[self.genderPicker selectedRowInComponent:0]];
    
    //如果从登录页面因为用户名错误，直接跳转到设置页面，先进性登录注册
    if (self.registerError) {
        UMComUserAccount *loginUserAccount = [UMComSession sharedInstance].currentUserAccount;
        loginUserAccount.name = self.nameField.text;
        loginUserAccount.gender = [NSNumber numberWithInteger:[self.genderPicker selectedRowInComponent:0]];

        [UMComLoginManager finishLoginWithAccount:loginUserAccount completion:^(NSArray *data, NSError *error) {
            if (error) {
                [UMComShowToast loginFail:error];
            } else {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.completion) {
                        self.completion(data,nil);
                    }
                }];
            }
        }];
    } else {
        [UMComHttpManager updateProfile:userAccount response:^(id responseObject, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateUserProfileSuccess object:self];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.completion) {
                        self.completion(nil,nil);
                    }
                }];
            } else {
                [UMComShowToast updateProfileFail:error];
                NSLog(@"update user profile fail!!");
            }
        }];
    }
    

}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == 20 && string.length > 0) {
        [self creatNoticeLabelWithView:textField];
        noticeLabel.text = UMComLocalizedString(@"The user nickname is too long", @"用户昵称过长") ;
        self.nameField.hidden = YES;
        noticeLabel.hidden = NO;
        string = @"";
        [self performSelector:@selector(hiddenNoticeView) withObject:nil afterDelay:0.8f];
        return NO;
    }
    if (string.length > 0 && [self isIncludeSpecialCharact:string]) {
        [self creatNoticeLabelWithView:textField];
        noticeLabel.text = UMComLocalizedString(@"The input character does not conform to the requirements", @"昵称只能包含中文、中英文字母、数字和下划线") ;
        noticeLabel.hidden = NO;
        self.nameField.hidden = YES;
        string = @"";
        [self performSelector:@selector(hiddenNoticeView) withObject:nil afterDelay:0.8f];
        return NO;
    }
    
    return YES;
}

- (void)creatNoticeLabelWithView:(UITextField *)textField
{
    if (!noticeLabel) {
        noticeLabel = [[UILabel alloc]initWithFrame:textField.frame];
        noticeLabel.backgroundColor = [UIColor clearColor];
        [textField.superview addSubview:noticeLabel];
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.textColor = [UIColor grayColor];
        noticeLabel.adjustsFontSizeToFitWidth = YES;
    }
}
- (void)hiddenNoticeView
{
    noticeLabel.hidden = YES;
    self.nameField.hidden = NO;
}
-(BOOL)isIncludeSpecialCharact:(NSString *)str {
    
    NSString *regex = @"(^[a-zA-Z0-9_\u4e00-\u9fa5]+$)";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isRight = ![pred evaluateWithObject:str];
    return isRight;
}

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