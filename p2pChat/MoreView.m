//
//  MoreView.m
//  p2pChat
//
//  Created by xiaokun on 16/1/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MoreView.h"
#import "Tool.h"
#import "AFNetworking.h"
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
        _imagePickerVC.allowsEditing = YES;
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

//- (void)sendPic {
//    if (_previewView != nil) {
//        [_previewView removeFromSuperview];
//    }
//    [_imagePickerVC dismissViewControllerAnimated:YES completion:nil];
//
//    [[MyXMPP shareInstance]sendPictureIdentifier:_localIdentifier data:_imageData thumbnailPath:_thumbnailPath ToUser:_chatObjectString];
//}

//- (void)cancel {
//    [_previewView removeFromSuperview];
//}

- (void)sendOriginalImageInfo:(NSNotification *)notification {

}

- (void)sendOriginalImage {

}


#pragma mark - image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    _image = info[UIImagePickerControllerOriginalImage];
    
    _thumbnailPath = [Tool getFileName:@"thumbnail" extension:@"jpeg"];
    UIImage *thumbnailImage = [_photoCenter makeThumbnail:_image WithSize:CGSizeMake(200, 200)];

    NSData *imageData = UIImagePNGRepresentation(_image);
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnailImage);
    [thumbnailData writeToFile:_thumbnailPath atomically:YES];
    
    if (_imagePickerVC.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {//图片来自图库
       
        NSURL *url = info[UIImagePickerControllerReferenceURL];//这个url和identifier相差一些字符
        _localIdentifier = [_photoCenter getLocalIdentifierFromPath:[url absoluteString]];
        
    } else {//图片来自拍照
        [_photoCenter saveImage:_image withCompletionHandler:^(NSString *identifier) {
            _localIdentifier = identifier;
        }];
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    NSString *filename = [NSString stringWithFormat:@"%@_%i",_chatObjectString,time];
    NSString *url = [NSString stringWithFormat:@"http://10.108.136.59:8080/FileServer/file?method=upload&filename=%@",filename];
    [self sendPic:imageData toServerUrl:url];
    
    [[MyXMPP shareInstance] sendPictureIdentifier:_localIdentifier data:thumbnailData thumbnailPath:_thumbnailPath netUrl:url ToUser:_chatObjectString];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendPic:(NSData *)imageData toServerUrl:(NSString *)stringUrl{
    
    NSLog(@"sendsendPic2Server");
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 参数para:{method:”upload”/”download”,filename:””}(filename格式：username_timestamp
    //     访问路径
//    NSString *stringURL = @"http://10.108.136.59:8080/FileServer/file?method=upload&filename=1123";
    
    [manager POST:stringUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 拼接文件参数
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"filename" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"success%@",json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed------error:   %@",error);
    }];
    
}
@end
