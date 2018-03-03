//
//  MFExtractColor.h
//  MFExtractColorDemo
//
//  Copyright © 2018年 GodzzZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MFExtractColor;
typedef void (^completionHandler) (MFExtractColor *);
@interface MFExtractColor : NSObject

@property (nonatomic, strong, readonly) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) UIColor *primaryColor;
@property (nonatomic, strong, readonly) UIColor *secondaryColor;
@property (nonatomic, strong, readonly) UIColor *detailColor;

+ (void)extractColorFromImage:(UIImage *)image
                       scaled:(CGSize)scaledSize
            completionHandler:(completionHandler)completionHandler;
@end
