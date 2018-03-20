//
//  YYAnimatedImage.h
//  YYDemo
//
//  Created by mac on 2017/7/31.
//  Copyright © 2017年 com.pinganfu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The YYAnimatedImage protocol declares the required methods for animated image
 display with YYAnimatedImageView.
 
 Subclass a UIImage and implement this protocol, so that instances of that class
 can be set to YYAnimatedImageView.image or YYAnimatedImageView.highlightedImage
 to display animation.
 
 See `YYImage` and `YYFrameImage` for example.
 */
@protocol YYAnimatedImage <NSObject>
@required
/// Total animated frame count.
/// It the frame count is less than 1, then the methods below will be ignored.
- (NSUInteger)animatedImageFrameCount;

/// Animation loop count, 0 means infinite looping.
- (NSUInteger)animatedImageLoopCount;

/// Bytes per frame (in memory). It may used to optimize memory buffer size.
- (NSUInteger)animatedImageBytesPerFrame;

/// Returns the frame image from a specified index.
/// This method may be called on background thread.
/// @param index  Frame index (zero based).
- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index;

/// Returns the frames's duration from a specified index.
/// @param index  Frame index (zero based).
- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index;

@optional
/// A rectangle in image coordinates defining the subrectangle of the image that
/// will be displayed. The rectangle should not outside the image's bounds.
/// It may used to display sprite animation with a single image (sprite sheet).
- (CGRect)animatedImageContentsRectAtIndex:(NSUInteger)index;
@end


NS_ASSUME_NONNULL_BEGIN

@interface YYAnimatedImage : UIImage < YYAnimatedImage >
- (nullable instancetype)initAnimatedImageWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
