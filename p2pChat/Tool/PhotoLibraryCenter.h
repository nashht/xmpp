//
//  PhotoLibraryCenter.h
//  p2pChat
//
//  Created by xiaokun on 16/1/18.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

/*
 自己发出去的照片，发送的是缩略图
 若拍照所得，则将图片保存在xmpp图库中
 
 图片在图库中的标识为 localIdentifier，不是 path
*/

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

extern CGSize thumbnailSize;

@interface PhotoLibraryCenter : NSObject

- (void)saveImage:(UIImage *)image withCompletionHandler:(void (^)(NSString *identifier))completionHandler;
- (void)getImageDataWithLocalIdentifier:(NSString *)identifier withCompletionHandler:(void (^)(NSData *imageData))completionHandler;
- (void)getImageWithLocalIdentifier:(NSString *)identifier withCompletionHandler:(void (^)(UIImage *image))completionHandler;;

- (UIImage *)makeThumbnail:(UIImage *)originalImage WithSize:(CGSize)size;
- (NSString *)getLocalIdentifierFromPath:(NSString *)path;

@end
