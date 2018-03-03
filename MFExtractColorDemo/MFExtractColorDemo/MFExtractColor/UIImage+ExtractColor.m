//
//  UIImage+ExtractColor.m
//  MFExtractColorDemo
//
//  Copyright © 2018年 GodzzZZZ. All rights reserved.
//

#import "UIImage+ExtractColor.h"

@implementation UIImage (ExtractColor)
- (UIImage *)scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
