//
//  YYAnimatedImage.m
//  YYDemo
//
//  Created by mac on 2017/7/31.
//  Copyright © 2017年 com.pinganfu. All rights reserved.
//

#import "YYAnimatedImage.h"
#import "YYImageCoder.h"
#import <ImageIO/ImageIO.h>


@implementation YYAnimatedImage
{
    YYImageDecoder *_decoder;
    CGImageSourceRef _imageSource;
    NSUInteger _bytesPerFrame;
}

- (nullable instancetype)initAnimatedImageWithData:(NSData *)data
{
    if (data.length > 0)
    {
        @autoreleasepool {
            YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:1];
            YYImageFrame *frame = [decoder frameAtIndex:0 decodeForDisplay:YES];
            UIImage *image = frame.image;
            if (image)
            {
                self = [self initWithCGImage:image.CGImage scale:decoder.scale orientation:image.imageOrientation];
                if (self)
                {
                    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, nil);
                    NSUInteger frameCount = CGImageSourceGetCount(imageSource);
                    if (frameCount > 1 && [[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
                    {
                        self->_imageSource = imageSource;
                    } else {
                        CFRelease(imageSource);
                    }
                    
                    frameCount = decoder.frameCount;
                    if (frameCount > 1)
                    {
                        _decoder = decoder;
                        _bytesPerFrame = CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage);
                    }
                    
                    return self;
                }
            }
        }
    }

    return nil;
}

- (void)dealloc
{
    if (_imageSource)
    {
        CFRelease(_imageSource);
    }
}

- (NSUInteger)animatedImageFrameCount
{
    return _decoder.frameCount;
}

- (NSUInteger)animatedImageLoopCount
{
    return _decoder.loopCount;
}

- (NSUInteger)animatedImageBytesPerFrame
{
    return _bytesPerFrame;
}

- (nullable UIImage *)animatedImageFrameAtIndex:(NSUInteger)index
{
    @autoreleasepool {
        if (_imageSource)
        {
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(_imageSource, index, (CFDictionaryRef)@{(__bridge id)kCGImageSourceShouldCache: @YES,(__bridge id)kCGImageSourceShouldCacheImmediately: @NO});
            if (cgImage)
            {
                UIImage *image = [UIImage imageWithCGImage:cgImage];
                CGImageRelease(cgImage);
                return image;
            }
        }
        
        return [_decoder frameAtIndex:index decodeForDisplay:YES].image;
    }
}

- (NSTimeInterval)animatedImageDurationAtIndex:(NSUInteger)index
{
    return [_decoder frameDurationAtIndex:index];
}
@end
