//
//  YYImage.m
//
//  Created by chendailong2014@126.com on 2017/7/22.
//  Copyright © 2017年 com.pinganfu. All rights reserved.
//

#import "YYImage.h"
#import "YYImageCoder.h"

@interface NSString (YYImage)
- (CGFloat)pathScale;
- (NSString *)stringByAppendingNameScale:(CGFloat)scale;
@end

@interface NSBundle (YYImage)
+ (NSArray *)preferredScales;
@end

@implementation YYImage

+ (UIImage *)imageNamed:(NSString *)name {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    NSArray *scales = [NSBundle preferredScales];
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = [res stringByAppendingNameScale:scale];
        NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp"];
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    
    return [[self class] imageWithData:data scale:scale];
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    return [[self class] imageWithData:data scale:path.pathScale];
}

+ (UIImage *)imageWithData:(NSData *)data {
    return [[self class] imageWithData:data scale:1.0];
}

+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale {
    UIImage *resultImage = nil;
    @autoreleasepool {
        YYImageDecoder *decoder = [YYImageDecoder decoderWithData:data scale:1];
        NSUInteger frameCount = decoder.frameCount;
 
        NSTimeInterval duration = 0;
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:frameCount];
        for (NSInteger index = 0; index < frameCount; index++)
        {
            @autoreleasepool {
                YYImageFrame *imageFrame = [decoder frameAtIndex:index decodeForDisplay:NO];
                duration += [decoder frameDurationAtIndex:index];
                UIImage *image = imageFrame.image;
                if (image)
                {
                    [images addObject:image];
                }
            }
        }
        
        resultImage = images.count <= 1 ? images.firstObject : [UIImage animatedImageWithImages:images duration:duration];
    }
    
    return resultImage;
}

+ (NSData *)imageDataWithImage:(UIImage *)image
{
    NSData *data = nil;
    
    YYImageEncoder *encoder = [[YYImageEncoder alloc] initWithType:YYImageTypePNG];
    NSUInteger frameCount = image.images.count;
    if (frameCount > 1)
    {
        NSTimeInterval duration = image.duration / frameCount;
        for (UIImage *frame in image.images)
        {
            [encoder addImage:frame duration:duration];
        }
        
        data = [encoder encode];
    } else {
        int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        BOOL imageIsPng = hasAlpha;
        
        if (imageIsPng) {
            data = UIImagePNGRepresentation(image);
        }
        else {
            data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        }
    }
    
    return data;
}

+ (NSData *)imageDataWithImage:(UIImage *)image rawData:(NSData *)rawData
{
    YYImageType type = YYImageDetectType((__bridge CFDataRef)(rawData));
    if (type == YYImageTypeWebP)
    {
        return [YYImage imageDataWithImage:image];
    }
    
    return rawData;
}

+ (NSString *)contentTypeWithImageData:(NSData *)data
{
    NSString *contentType = @"";
    YYImageType type = YYImageDetectType((__bridge CFDataRef)(data));
    switch (type) {
        case YYImageTypeUnknown:
            break;
        case YYImageTypeJPEG:
        case YYImageTypeJPEG2000:
            contentType = @"image/jpeg";
            break;
        case YYImageTypeTIFF:
            contentType = @"image/tiff";
            break;
        case YYImageTypeBMP:
            contentType = @"image/bmp";
            break;
        case YYImageTypeICO:
            contentType = @"image/x-icon";
            break;
        case YYImageTypeICNS:
            contentType = @"image/x-icns";
            break;
        case YYImageTypeGIF:
            contentType = @"image/gif";
            break;
        case YYImageTypePNG:
            contentType = @"image/png";
            break;
        case YYImageTypeWebP:
            contentType = @"image/webp";
            break;
        case YYImageTypeOther:
            break;
        default:
            break;
    }
    
    return nil;
}

@end

@implementation NSString (YYImage)

- (NSString *)stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (CGFloat)pathScale {
    if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
    NSString *name = self.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    [name enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines usingBlock: ^(NSString *match, NSRange matchRange, BOOL *stop) {
        scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
    }];
    return scale;
}

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

@end

@implementation NSBundle (YYImage)

+ (NSArray *)preferredScales {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

@end
