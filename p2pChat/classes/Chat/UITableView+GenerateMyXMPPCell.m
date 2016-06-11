//
//  UITableView+GenerateMyXMPPCell.m
//  XMPP
//
//  Created by xiaokun on 16/6/11.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "UITableView+GenerateMyXMPPCell.h"
#import "MessageBean.h"
#import "MyXMPP.h"

const NSString *textReuseIdentifier = @"textMessageCell";
const NSString *audioReuseIdentifier = @"audioMessageCell";
const NSString *pictureReuseIdentifier = @"pictureMessageCell";
const NSString *fileReuseIdentifier = @"fileMessageCell";

@implementation UITableView (GenerateMyXMPPCell)

- (UITableViewCell *)dequeueMyXMPPCellFromMessage:(MessageBean *)message {
    MessageType type = message.type.charValue;
    switch (type) {
        case MessageTypeMessage:{
            MessageViewCell *cell = [self dequeueReusableCellWithIdentifier:textReuseIdentifier];
            
            if (cell == nil) {
                cell = [[MessageViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:textReuseIdentifier];
            }
            MessageFrameModel *messageFrameModel = [[MessageFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.messageFrame = messageFrameModel;
            return cell;
        }
            
        case MessageTypeRecord:{
            RecordViewCell *cell = [self dequeueReusableCellWithIdentifier:audioReuseIdentifier];
            
            if (cell == nil) {
                cell = [[RecordViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:audioReuseIdentifier];
            }
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
            recordFrameMode.message = message;
            cell.recordFrame = recordFrameMode;
            return cell;
        }
            
        case MessageTypePicture:{
            PicViewCell *cell = [self dequeueReusableCellWithIdentifier:pictureReuseIdentifier];
            
            if (cell == nil) {
                cell = [[PicViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:pictureReuseIdentifier];
            }
            
            PicFrameModel *messageFrameModel = [[PicFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.picFrame = messageFrameModel;
            return cell;
        }
        case MessageTypeFile:{
            FileCell *cell = [self dequeueReusableCellWithIdentifier:fileReuseIdentifier];
            
            if (cell == nil) {
                cell = [[FileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileReuseIdentifier];
            }
            
            FileFrameModel *fileFrameMode = [[FileFrameModel alloc] init];
            fileFrameMode.message = message;
            cell.fileFrame = fileFrameMode;
            return cell;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (CGFloat)heightOfMessage:(MessageBean *)message {
    MessageType type = message.type.charValue;
    switch (type) {
        case MessageTypeMessage:{
            MessageFrameModel *messageFrameModel = [[MessageFrameModel alloc] init];
            messageFrameModel.message = message;
            return messageFrameModel.cellHeight + 1;
        }
            break;
        case MessageTypePicture:{
            PicFrameModel *picFrameModel = [[PicFrameModel alloc] init];
            picFrameModel.message = message;
            return picFrameModel.cellHeight + 1;
        }
            break;
        case MessageTypeRecord:{
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
            recordFrameMode.message = message;
            return recordFrameMode.cellHeight + 1;
        }
            break;
        case MessageTypeFile:{
            FileFrameModel *fileFrameModel = [[FileFrameModel alloc] init];
            fileFrameModel.message = message;
            return fileFrameModel.cellHeight + 1;
        }
        default:
            break;
    }
    return 0;
}

@end
