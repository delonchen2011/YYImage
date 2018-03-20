//
//  YYImage.h
//  YYDemo
//
//  Created by chendailong2014@126.com on 2017/7/22.
//  Copyright © 2017年 com.pinganfu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYImage : NSObject
+ (nullable UIImage *)imageNamed:(NSString *)name; // no cache!
+ (nullable UIImage *)imageWithContentsOfFile:(NSString *)path;
+ (nullable UIImage *)imageWithData:(NSData *)data;
+ (nullable UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
+ (nullable NSData *)imageDataWithImage:(UIImage *)image;
+ (nullable NSData *)imageDataWithImage:(UIImage *)image rawData:(NSData *)rawData;
+ (NSString *)contentTypeWithImageData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
