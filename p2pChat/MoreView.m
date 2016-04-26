//
//  MoreView.m
//  p2pChat
//
//  Created by xiaokun on 16/1/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MoreView.h"
#import "Tool.h"
#import "DataManager.h"
#import "PhotoLibraryCenter.h"
#import "MyXMPP+P2PChat.h"
#import "MyXMPP+Group.h"

@interface MoreView () {
    int imagePiecesNum;
}
@property (strong, nonatomic) PhotoLibraryCenter *photoCenter;

@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *localIdentifier;
@property (strong, nonatomic) NSString *thumbnailPath;

@property (strong, nonatomic) UIView *previewView;

@end

@implementation MoreView
- (void) awakeFromNib {
    _photoCenter = [[PhotoLibraryCenter alloc]init];
}

- (IBAction)pickPicture:(id)sender {
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc]init];
        _imagePickerVC.delegate = self;
    }
    _imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIViewController *superVC = [self viewController];
    [superVC presentViewController:_imagePickerVC animated:YES completion:nil];
}

- (IBAction)pickPhoto:(id)sender {
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc]init];
        _imagePickerVC.delegate = self;
    }
    _imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePickerVC.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    UIViewController *superVC = [self viewController];
    [superVC presentViewController:_imagePickerVC animated:YES completion:nil];
}

- (UIViewController *)viewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)sendPic {
    if (_previewView != nil) {
        [_previewView removeFromSuperview];
    }
    [_imagePickerVC dismissViewControllerAnimated:YES completion:nil];

    [[MyXMPP shareInstance]sendPictureIdentifier:_localIdentifier data:_imageData thumbnailPath:_thumbnailPath ToUser:_chatObjectString];
}

- (void)cancel {
    [_previewView removeFromSuperview];
}

- (void)sendOriginalImageInfo:(NSNotification *)notification {

}

- (void)sendOriginalImage {

}

- (void)initPreview {
    _previewView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _previewView.backgroundColor = [UIColor whiteColor];
    _previewView.alpha = 0.98;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame = CGRectMake(15, 20, 50, 30);
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"cancel" forState:UIControlStateNormal];
    [_previewView addSubview:cancelBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(size.width - 65, 20, 50, 30);
    [sendBtn addTarget:self action:@selector(sendPic) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setTitle:@"send" forState:UIControlStateNormal];
    [_previewView addSubview:sendBtn];
}

#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    _image = info[UIImagePickerControllerOriginalImage];
    _thumbnailPath = [Tool getFileName:@"thumbnail" extension:@"png"];
    UIImage *thumbnailImage = [_photoCenter makeThumbnail:_image WithSize:CGSizeMake(100, 100)];
    [UIImagePNGRepresentation(thumbnailImage) writeToFile:_thumbnailPath atomically:YES];
    
    if (_imagePickerVC.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {//图片来自图库
        [self initPreview];
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];//这个url和identifier相差一些字符
        _localIdentifier = [_photoCenter getLocalIdentifierFromPath:[url absoluteString] ];
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGFloat scale = MIN(size.width / _image.size.width, size.height / _image.size.height);
        UIImageView *imageView = [[UIImageView alloc]initWithImage:_image];
        imageView.frame = CGRectMake((size.width - _image.size.width * scale) / 2, (size.height - _image.size.height * scale) / 2, _image.size.width * scale, _image.size.height * scale);
        [_previewView addSubview:imageView];
        [picker.view addSubview:_previewView];
        
        [_photoCenter getImageDataWithLocalIdentifier:_localIdentifier withCompletionHandler:^(NSData *imageData) {
            _imageData = imageData;
        }];
    } else {//图片来自拍照
        [_photoCenter saveImage:_image withCompletionHandler:^(NSString *identifier, NSString *thumbnailPath) {
            _localIdentifier = identifier;
            [self sendPic];
        }];
    }
}

@end
