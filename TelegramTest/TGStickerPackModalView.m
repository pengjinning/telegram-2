//
//  TGStickerPackModalView.m
//  Telegram
//
//  Created by keepcoder on 08.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGStickerPackModalView.h"
#import "TGAllStickersTableView.h"
#import "EmojiViewController.h"
#import "TGMessagesStickerImageObject.h"
#import "TGImageView.h"
@interface TGStickerPackModalView ()
@property (nonatomic,strong) TGAllStickersTableView *tableView;

@property (nonatomic,strong) TL_messages_stickerSet *pack;
@property (nonatomic,strong) BTRButton *addButton;
@property (nonatomic,strong) TMTextField *nameField;
@property (nonatomic,strong) TGImageView *packHeaderImageView;
@property (nonatomic,strong) BTRButton *closeButton;
@property (nonatomic,strong) TMView *headerView;
@property (nonatomic,strong) TMView *bottomView;
@end

@implementation TGStickerPackModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


static NSImage * greenBackgroundImage(NSSize size) {
    static NSImage *image = nil;

    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    image = [[NSImage alloc] initWithSize:rect.size];
    [image lockFocus];
    [NSColorFromRGB(0x54c759) set];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:14 yRadius:14];
    [path fill];
    
    [image unlockFocus];
    return image;//image_VideoPlay();
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        [self setContainerFrameSize:NSMakeSize(300, 380)];
        
        _tableView = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(0, 50, self.containerSize.width, self.containerSize.height - 130 )];
        
        [self addSubview:_tableView.containerView];
        
        
        
        _bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, 50)];
        
        _bottomView.backgroundColor = NSColorFromRGB(0xfafafa);
        
        [self addSubview:_bottomView];
    
        
        TMView *bottomSeparator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, self.containerSize.width, 1)];
        
        bottomSeparator.backgroundColor = GRAY_BORDER_COLOR;
        
        _addButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, 130, 27)];
        
        [_addButton setTitleFont:TGSystemMediumFont(14) forControlState:BTRControlStateNormal];
        
        [_addButton setTitleColor:[NSColor whiteColor] forControlState:BTRControlStateNormal];
        
        [_addButton setTitle:NSLocalizedString(@"StickerPack.AddStickerPack", nil) forControlState:BTRControlStateNormal];
        
        weak();
        
        [_addButton addBlock:^(BTRControlEvents events) {
            
            
            [RPCRequest sendRequest:[TLAPI_messages_installStickerSet createWithStickerset:[TL_inputStickerSetID createWithN_id:weakSelf.pack.set.n_id access_hash:weakSelf.pack.set.access_hash]] successHandler:^(id request, id response) {
                
                [weakSelf close:YES];
                
                [EmojiViewController reloadStickers];
                
            } errorHandler:^(id request, RpcError *error) {
                
            } timeout:10];
            
        } forControlEvents:BTRControlEventMouseDownInside];
        
        
        
        
        [_addButton setCenterByView:_bottomView];
        
        [_bottomView addSubview:bottomSeparator];
        [_bottomView addSubview:_addButton];
        
        
        
        
        _headerView = [[TMView alloc] initWithFrame:NSMakeRect(0, self.containerSize.height - 80, self.containerSize.width, 80)];
        
        _headerView.backgroundColor = NSColorFromRGB(0xfafafa);
        
        [self addSubview:_headerView];
        
        
        
        _nameField = [TMTextField defaultTextField];
        
        [_nameField setFrame:NSMakeRect(0, 15, self.containerSize.width, 27)];
        [_nameField setAlignment:NSCenterTextAlignment];
        [_nameField setTextColor:TEXT_COLOR];
        [_nameField setFont:TGSystemFont(13)];
        
        [_headerView addSubview:_nameField];
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_headerView.frame), 1)];
        
        separator.backgroundColor = GRAY_BORDER_COLOR;
        
        [_headerView addSubview:separator];
        
        
        _packHeaderImageView = [[TGImageView alloc] initWithFrame:NSMakeRect(10, 10, 0, 0)];
        
        [_headerView addSubview:_packHeaderImageView];
        
        _closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(_headerView.frame) - image_CancelReply().size.width - 10, NSHeight(_headerView.frame) - image_CancelReply().size.height - 10, image_CancelReply().size.width, image_CancelReply().size.height)];
        
        [_closeButton setImage:image_CancelReply() forControlState:BTRControlStateNormal];
        
        
        [_closeButton addBlock:^(BTRControlEvents events) {
            [weakSelf close:YES];
        } forControlEvents:BTRControlEventMouseDownInside];
        
        [_headerView addSubview:_closeButton];


    }
    
    return self;
}


-(void)setStickerPack:(TL_messages_stickerSet *)stickerPack {
    
    _pack = stickerPack;
    
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
    
    
    NSRange range = [title appendString:_pack.set.title withColor:TEXT_COLOR];
    
    [title setFont:TGSystemFont(15) forRange:range];
    
    [title appendString:@"\n"];
    
    range = [title appendString:[NSString stringWithFormat:NSLocalizedString(@"Stickers.StickersCount", nil), stickerPack.documents.count] withColor:GRAY_TEXT_COLOR];
    
    [title setFont:TGSystemFont(13) forRange:range];
    
    
    
    
    [_nameField setAttributedStringValue:title];
    [_nameField sizeToFit];
    
    
    
    [_tableView showWithStickerPack:stickerPack];
    
    __block BOOL packIsset = NO;
    
    
    __block TLDocument *headerSticker;
    
    [[stickerPack documents] enumerateObjectsUsingBlock:^(TLDocument *obj, NSUInteger idx, BOOL *stop) {
        
        if(idx == 0)
            headerSticker = obj;
        
        NSArray *filter = [[EmojiViewController allStickers] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.n_id == %ld",obj.n_id]];
        
        if(filter.count > 0) {
            packIsset = YES;
            *stop = YES;
        }
        
    }];
    
    
    NSUInteger dif = stickerPack.documents.count/4;
    
    if(dif < 4) {
        [self setContainerFrameSize:NSMakeSize(self.containerSize.width, 80 + dif*80)];
    }
    
    NSImage *placeholder = [[NSImage alloc] initWithData:headerSticker.thumb.bytes];
    
    if(!placeholder)
        placeholder = [NSImage imageWithWebpData:headerSticker.thumb.bytes error:nil];
    
    TGMessagesStickerImageObject *imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:headerSticker.thumb.location placeHolder:placeholder];
    imageObject.imageSize = strongsize(NSMakeSize(headerSticker.thumb.w, headerSticker.thumb.h), 50);
    
    _packHeaderImageView.object = imageObject;
    [_packHeaderImageView setFrameSize:imageObject.imageSize];
    
    [_packHeaderImageView setCenteredYByView:_headerView];
    
    
    [_nameField setFrameOrigin:NSMakePoint(NSMaxX(_packHeaderImageView.frame) + 10, 0)];
    
    [_nameField setCenteredYByView:_headerView];
    
    [_tableView.containerView setFrame:NSMakeRect(0, packIsset ? 0 : 50, self.containerSize.width, packIsset ? self.containerSize.height - 80 : self.containerSize.height - 130)];
    
    [_bottomView setHidden:packIsset];
    
    [_addButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"StickerPack.AddStickerPack", nil),stickerPack.documents.count] forControlState:BTRControlStateNormal];
  
    [_addButton setBackgroundImage:greenBackgroundImage(NSMakeSize(130, 27)) forControlState:BTRControlStateNormal];
    
    
    [_headerView setFrameOrigin:NSMakePoint(0, self.containerSize.height - 80)];
        
}


@end
