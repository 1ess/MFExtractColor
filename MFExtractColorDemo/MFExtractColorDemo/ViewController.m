//
//  ViewController.m
//  MFExtractColorDemo
//
//  Copyright © 2018年 GodzzZZZ. All rights reserved.
//

#import "ViewController.h"
#import "MFExtractColor.h"
#import <Photos/Photos.h>
@interface ViewController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MFExtractColor *extractColor;
@property (nonatomic, strong) UIView *backgroundColorView;
@property (nonatomic, strong) UILabel *primaryColorLabel;
@property (nonatomic, strong) UILabel *secondaryColorLabel;
@property (nonatomic, strong) UILabel *detailColorLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100 + CGRectGetWidth(self.view.frame) - 20)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.alpha = 0;
    [self.view addSubview:self.containerView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, CGRectGetWidth(self.view.frame) - 100, CGRectGetWidth(self.view.frame) - 20)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    [self.containerView addSubview:self.imageView];
    
    self.backgroundColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, CGRectGetWidth(self.view.frame) - 20)];
    self.backgroundColorView.backgroundColor = self.extractColor.backgroundColor;
    [self.containerView addSubview:self.backgroundColorView];
    
    
    self.primaryColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 80, 50)];
    self.primaryColorLabel.text = @"primary color text";
    self.primaryColorLabel.font = [UIFont systemFontOfSize:15];
    self.primaryColorLabel.numberOfLines = 0;
    self.primaryColorLabel.textColor = self.extractColor.primaryColor;
    [self.backgroundColorView addSubview:self.primaryColorLabel];
    
    self.secondaryColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.primaryColorLabel.frame), 80, 50)];
    self.secondaryColorLabel.text = @"secondary color text";
    self.secondaryColorLabel.font = [UIFont systemFontOfSize:15];
    self.secondaryColorLabel.numberOfLines = 0;
    self.secondaryColorLabel.textColor = self.extractColor.secondaryColor;
    [self.backgroundColorView addSubview:self.secondaryColorLabel];
    
    self.detailColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.secondaryColorLabel.frame), 80, 50)];
    self.detailColorLabel.text = @"detail color text";
    self.detailColorLabel.font = [UIFont systemFontOfSize:15];
    self.detailColorLabel.numberOfLines = 0;
    self.detailColorLabel.textColor = self.extractColor.detailColor;
    [self.backgroundColorView addSubview:self.detailColorLabel];
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.imageView.frame) + 50, CGRectGetWidth(self.view.frame) - 20, 50)];
    [btn setTitle:@"choose" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setExtractColor:(MFExtractColor *)extractColor {
    _extractColor = extractColor;
    self.backgroundColorView.backgroundColor = extractColor.backgroundColor;
    self.primaryColorLabel.textColor = extractColor.primaryColor;
    self.secondaryColorLabel.textColor = extractColor.secondaryColor;
    self.detailColorLabel.textColor = extractColor.detailColor;
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.alpha = 1;
    }];
}

- (void)click {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        self.containerView.alpha = 0;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        PHAsset *asset = nil;
        if (@available(iOS 11.0, *)) {
            asset = [info objectForKey:UIImagePickerControllerPHAsset];
        } else {
            NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
            asset = [result firstObject];
            
        }
        [self getPhotoWithAsset:asset progress:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            //不走这个callback，不知道什么bug
        } completion:^(UIImage *image, NSDictionary *info) {
            self.imageView.image = image;
            [MFExtractColor extractColorFromImage:image scaled:CGSizeMake(512, 512) completionHandler:^(MFExtractColor *extractColor) {
                self.extractColor = extractColor;
            }];
        }];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)getPhotoWithAsset:(PHAsset *)asset progress:(PHAssetImageProgressHandler)progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = progressHandler;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            if (completion) dispatch_async(dispatch_get_main_queue(), ^{
                completion(result, info);
            });
        }
    }];
}

@end
