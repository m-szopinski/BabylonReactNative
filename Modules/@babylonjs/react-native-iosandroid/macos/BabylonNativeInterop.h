#pragma once

#import <MetalKit/MetalKit.h>
#import <React/RCTBridge.h>

@interface BabylonNativeInterop : NSObject
+ (void)initialize:(RCTBridge*)bridge;
+ (void)updateView:(MTKView*)mtkView;
+ (void)updateMSAA:(NSNumber*)value;
+ (void)renderView;
+ (void)resetView;
+ (void)updateXRView:(MTKView*)mtkView;
+ (bool)isXRActive;
+ (void)reportMouseEvent:(MTKView*)mtkView event:(NSEvent*)event;
@end