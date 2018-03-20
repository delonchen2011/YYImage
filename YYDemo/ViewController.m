//
//  ViewController.m
//  YYDemo
//
//  Created by chendailong2014@126.com on 2017/7/22.
//  Copyright © 2017年 com.pinganfu. All rights reserved.
//

#import "ViewController.h"
#import "YYImage.h"
#import "YYAnimatedImage.h"

@interface ViewController () < NSCacheDelegate >
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView0;
- (IBAction)onClick:(id)sender;

@end

@implementation ViewController
{
    NSCache *_cache;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSLog(@"%@",obj);
}
- (void)viewDidLoad {
    _cache = [[NSCache alloc] init];
    _cache.countLimit = 3;
    _cache.delegate = self;
    
    [_cache setObject:@"0" forKey:@"00"];
    [_cache setObject:@"1" forKey:@"01"];
    [_cache setObject:@"2" forKey:@"02"];
    
    [_cache objectForKey:@"01"];
    
    [_cache setObject:@"3" forKey:@"03"];
    [_cache setObject:@"4" forKey:@"04"];
    NSData *datax = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://test3-ms.stg.1qianbao.com/v5/images/2017/8/z51501661085666_1_3x.webp"]];
    [datax writeToFile:@"/Users/mac/Desktop/1.webp" atomically:YES];
    
    [YYImage imageWithData:datax];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"w" ofType:@"png"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    self.imageView.image = [[YYAnimatedImage alloc] initAnimatedImageWithData:data];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"b1" ofType:@"png"];
    data = [[NSData alloc] initWithContentsOfFile:filePath];
    self.imageView0.image = [[YYAnimatedImage alloc] initAnimatedImageWithData:data];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClick:(id)sender {
    if (self.imageView0.animating)
    {
        [self.imageView0 stopAnimating];
    } else {
        [self.imageView0 startAnimating];
    }
}
@end
