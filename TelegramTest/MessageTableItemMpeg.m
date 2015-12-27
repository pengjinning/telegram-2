
//
//  MessageTableItemMpeg.m
//  Telegram
//
//  Created by keepcoder on 10/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "MessageTableItemMpeg.h"
#import "TGBlurImageObject.h"
#import "DownloadQueue.h"
#import "TGThumbnailObject.h"
#import "DownloadDocumentItem.h"
@interface MessageTableItemMpeg () {
    NSString *_path;
}
@property (nonatomic,strong) TL_documentAttributeVideo *imagesize;
@end

@implementation MessageTableItemMpeg


-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        _imagesize = (TL_documentAttributeVideo *) [object.media.document attributeWithClass:[TL_documentAttributeVideo class]];
        
        [self doAfterDownload];
        
        
        [self checkStartDownload:0 size:[self size]];
        
    }
    
    return self;
}

-(TL_documentAttributeVideo *)imagesize {
    
    __block TL_documentAttributeVideo *imageSize = _imagesize;
    
    if(imageSize == nil) {
        
        dispatch_block_t thumbblock = ^{
            if(![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]])  {
                imageSize = [TL_documentAttributeVideo createWithDuration:0 w:self.message.media.document.thumb.w * 3 h:self.message.media.document.thumb.h * 3];
            } else {
                imageSize = [TL_documentAttributeVideo createWithDuration:0 w:300 h:300];
            }
        };
        
        if(self.isset) {
            
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.path]];
            
            if(asset.naturalSize.width > 0 && asset.naturalSize.height > 0) {
                 _imagesize = imageSize = [TL_documentAttributeVideo createWithDuration:CMTimeGetSeconds([asset duration]) w:[asset naturalSize].width h:[asset naturalSize].height];
            } else {
                thumbblock();
            }
            
            
        } else {
            thumbblock();
        }
    }
    
    return imageSize;
}

-(void)doAfterDownload {
    [super doAfterDownload];
    
    if(![self.message.media.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
        _thumbObject = [[TGBlurImageObject alloc] initWithLocation:self.message.media.document.thumb.location thumbData:self.message.media.document.thumb.bytes size:self.message.media.document.thumb.size];
        _thumbObject.imageSize = NSMakeSize(self.imagesize.w, self.imagesize.h);
    }
    
}

-(Class)downloadClass {
    return [DownloadDocumentItem class];
}

-(DownloadItem *)downloadItem {
    
    if(super.downloadItem == nil) {
        [super setDownloadItem:[DownloadQueue find:self.message.media.document.n_id]];
    }
    
    return [super downloadItem];
}



-(int)size {
    return self.message.media.document.size;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = strongsize(NSMakeSize(self.imagesize.w, self.imagesize.h), width - 60);
    
    return YES;
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size {
    
    if((self.size <= 10*1024*1024 && !self.downloadItem && !self.isset) || (self.downloadItem && self.downloadItem.downloadState != DownloadStateCanceled)) {
        [self startDownload:NO force:YES];
    }
    
}

- (BOOL)isset {
    BOOL isset = isPathExists([self path]) && (fileSize([self path]) >= self.size || [self.message.media.document isKindOfClass:[TL_externalDocument class]]);
    
    return isset;
}

-(NSString *)path {
    return  mediaFilePath(self.message);
}

@end