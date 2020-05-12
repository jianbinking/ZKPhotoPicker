//
//  ViewController.m
//  ZKPhotoPickerOCDemo
//
//  Created by Doby on 2020/5/12.
//  Copyright © 2020 Doby. All rights reserved.
//

#import "ViewController.h"

@import ZKPhotoPicker;
@import Photos;
@interface ViewController ()<ZKPhotoPickerDelegate>

@property (strong, nonatomic) NSMutableArray<PHAsset*> *selectedAssets;
@property (strong, nonatomic) NSMutableDictionary<NSNumber*,UIImageView*> *dicImgvs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedAssets = [NSMutableArray array];
    self.dicImgvs = [NSMutableDictionary dictionary];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"test" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    __block CGFloat xoff = 250;
    __block CGFloat yoff = 100;
    [[self.dicImgvs.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1 > obj2;
    }] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imgv = self.dicImgvs[obj];
        imgv.frame = CGRectMake(xoff, yoff, 100, 100);
        xoff += 110;
        if (xoff + 110 > self.view.frame.size.width) {
            xoff = 10;
            yoff += 110;
        }
    }];
}

- (void)test {
    [ZKPhotoPicker showPickerViewIn:self delegate:self config:[ZKPhotoPickerConfig new] selectedAssets:self.selectedAssets authorizeFailHandle:^(PHAuthorizationStatus status) {
        
    }];
}


- (void)photoPickerWithPicker:(ZKPhotoPicker *)picker didFinishPick:(NSArray<PHAsset *> *)selectedAssets {
    self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
    [self.dicImgvs.allValues enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.image = nil;
    }];
    [self.selectedAssets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *v = self.dicImgvs[@(idx)];
        if (!v) {
            v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [self.view addSubview:v];
            [self.dicImgvs setObject:v forKey:@(idx)];
        }
        [obj zkOCFetchImageWithTargetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeDefault usePlaceholder:NO deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat completeHandle:^(UIImage * _Nullable img, BOOL isPlaceHolder, NSError * _Nullable error) {
            v.image = img;
        }];
    }];
}

@end
