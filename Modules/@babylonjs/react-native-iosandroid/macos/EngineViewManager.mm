#import "BabylonNativeInterop.h"

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <ReactCommon/CallInvoker.h>

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>

@interface EngineView : MTKView

@property (nonatomic, copy) RCTDirectEventBlock onSnapshotDataReturned;
@property (nonatomic, assign) BOOL isTransparent;
@property (nonatomic, assign) NSNumber* antiAliasing;

@end

@implementation EngineView {
    const RCTBridge* bridge;
    MTKView* xrView;
    NSTrackingArea* trackingArea;
}

- (instancetype)init:(RCTBridge*)_bridge {
    if (self = [super initWithFrame:CGRectZero device:MTLCreateSystemDefaultDevice()]) {
        bridge = _bridge;
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
        
        // Setup mouse tracking for macOS
        [self updateTrackingAreas];
    }
    return self;
}

- (void)updateTrackingAreas {
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
    }
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options:(NSTrackingActiveInActiveApp | 
                                                        NSTrackingMouseEnteredAndExited | 
                                                        NSTrackingMouseMoved |
                                                        NSTrackingInVisibleRect)
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setIsTransparentFlag:(NSNumber*)isTransparentFlag {
    BOOL isTransparent = [isTransparentFlag intValue] == 1;
    if(isTransparent){
        [self setLayer:self.layer];
        self.layer.opaque = NO;
    } else {
        [self setLayer:self.layer];
        self.layer.opaque = YES;
    }
    self.isTransparent = isTransparent;
}

- (void)setMSAA:(NSNumber*)value {
    [BabylonNativeInterop updateMSAA:value];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [BabylonNativeInterop updateView:self];
    [self updateTrackingAreas];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [BabylonNativeInterop updateView:self];
    [self updateTrackingAreas];
}

// Mouse event handling for macOS
- (void)mouseDown:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)mouseUp:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)rightMouseDown:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)rightMouseUp:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)otherMouseDown:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)otherMouseUp:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)mouseDragged:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)rightMouseDragged:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)otherMouseDragged:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)mouseMoved:(NSEvent*)event {
    [BabylonNativeInterop reportMouseEvent:self event:event];
}

- (void)drawRect:(CGRect)rect {
    if ([BabylonNativeInterop isXRActive]) {
        if (!xrView) {
            xrView = [[MTKView alloc] initWithFrame:self.bounds device:self.device];
            xrView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self addSubview:xrView];
            [BabylonNativeInterop updateXRView:xrView];
        }
    } else if (xrView) {
        [BabylonNativeInterop updateXRView:nil];
        [xrView removeFromSuperview];
        xrView = nil;
    }

    [BabylonNativeInterop renderView];
}

-(void)dealloc {
    [BabylonNativeInterop updateXRView:nil];
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
    }
}

- (void)takeSnapshot {
    // We must take the screenshot on the main thread otherwise we might fail to get a valid handle on the view's image.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create a bitmap representation of the view
        NSRect bounds = self.bounds;
        NSBitmapImageRep* bitmapRep = [self bitmapImageRepForCachingDisplayInRect:bounds];
        [self cacheDisplayInRect:bounds toBitmapImageRep:bitmapRep];
        
        // Convert to NSImage and then to JPEG data
        NSImage* image = [[NSImage alloc] initWithSize:bounds.size];
        [image addRepresentation:bitmapRep];
        
        CGImageRef cgImage = [bitmapRep CGImage];
        NSBitmapImageRep* jpegRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
        NSData* jpgData = [jpegRep representationUsingType:NSBitmapImageFileTypeJPEG properties:@{NSImageCompressionFactor: @0.8}];
        NSString* encodedData = [jpgData base64EncodedStringWithOptions:0];
        
        // Fire the onSnapshotDataReturned event if hooked up.
        if (self.onSnapshotDataReturned != nil) {
            self.onSnapshotDataReturned(@{ @"data":encodedData});
        }
    });
}

@end


@interface EngineViewManager : RCTViewManager
@end

@implementation EngineViewManager

RCT_CUSTOM_VIEW_PROPERTY(isTransparent, NSNumber*, EngineView){
    [view setIsTransparentFlag:json];
}

RCT_CUSTOM_VIEW_PROPERTY(antiAliasing, NSNumber*, EngineView){
    [view setMSAA:json];
}

RCT_EXPORT_MODULE(EngineViewManager)

RCT_EXPORT_VIEW_PROPERTY(onSnapshotDataReturned, RCTDirectEventBlock)

RCT_EXPORT_METHOD(takeSnapshot:(nonnull NSNumber*) reactTag) {
    // Marshal the takeSnapshot call to the appropriate EngineView.
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber*,NSView*>* viewRegistry) {
        EngineView* view = (EngineView*)viewRegistry[reactTag];
        if (!view || ![view isKindOfClass:[EngineView class]]) {
            return;
        }
        [view takeSnapshot];
    }];
}

- (NSView*)view {
    return [[EngineView alloc] init:self.bridge];
}

@end