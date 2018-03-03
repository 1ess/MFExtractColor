//
//  MFExtractColor.m
//  MFExtractColorDemo
//
//  Copyright © 2018年 GodzzZZZ. All rights reserved.
//

#import "MFExtractColor.h"
#import "UIImage+ExtractColor.h"

@interface UIColor(MFColor)

- (BOOL)mf_isDarkColor;
- (BOOL)mf_isDistinct:(UIColor *)compareColor;
- (UIColor *)mf_colorWithMinimumSaturation:(CGFloat)minSaturation;
- (BOOL)mf_isBlackOrWhite;
- (BOOL)mf_isContrastingColor:(UIColor *)color;

@end

@implementation UIColor(MFColor)
- (BOOL)mf_isDarkColor {
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    if (lum < .5) {
        return YES;
    }
    return NO;
}

- (BOOL)mf_isDistinct:(UIColor *)compareColor {
    CGFloat r, g, b, a;
    CGFloat r1, g1, b1, a1;
    [self getRed:&r green:&g blue:&b alpha:&a];
    [compareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    CGFloat threshold = .25; //.15
    
    if (fabs(r - r1) > threshold ||
        fabs(g - g1) > threshold ||
        fabs(b - b1) > threshold ||
        fabs(a - a1) > threshold) {
        // check for grays, prevent multiple gray colors
        if (fabs(r - g) < .03 && fabs(r - b) < .03) {
            if (fabs(r1 - g1) < .03 && fabs(r1 - b1) < .03)
                return NO;
        }
        return YES;
    }
    return NO;
}

- (UIColor *)mf_colorWithMinimumSaturation:(CGFloat)minSaturation {
    if (self) {
        CGFloat hue = 0.0;
        CGFloat saturation = 0.0;
        CGFloat brightness = 0.0;
        CGFloat alpha = 0.0;
        [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        if (saturation < minSaturation) {
            return [UIColor colorWithHue:hue saturation:minSaturation brightness:brightness alpha:alpha];
        }
    }
    return self;
}

- (BOOL)mf_isBlackOrWhite {
    if (self) {
        CGFloat r, g, b, a;
        [self getRed:&r green:&g blue:&b alpha:&a];
        if (r > .91 && g > .91 && b > .91)
            return YES; // white
        
        if (r < .09 && g < .09 && b < .09)
            return YES; // black
    }
    return NO;
}

- (BOOL)mf_isContrastingColor:(UIColor *)color {
    if (self && color) {
        CGFloat br, bg, bb, ba;
        CGFloat fr, fg, fb, fa;
        [self getRed:&br green:&bg blue:&bb alpha:&ba];
        [color getRed:&fr green:&fg blue:&fb alpha:&fa];
        CGFloat bLum = 0.2126 * br + 0.7152 * bg + 0.0722 * bb;
        CGFloat fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb;
        CGFloat contrast = 0.;
        if ( bLum > fLum )
            contrast = (bLum + 0.05) / (fLum + 0.05);
        else
            contrast = (fLum + 0.05) / (bLum + 0.05);
        //return contrast > 3.0; //3-4.5 W3C recommends 3:1 ratio, but that filters too many colors
        return contrast > 1.6;
    }
    return YES;
}
@end

@interface MFCountedColor : NSObject

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithColor:(UIColor *)color count:(NSUInteger)count;

@end

@implementation MFCountedColor

- (instancetype)initWithColor:(UIColor *)color count:(NSUInteger)count {
    self = [super init];
    if (self) {
        self.color = color;
        self.count = count;
    }
    return self;
}

- (NSComparisonResult)compare:(MFCountedColor *)object {
    if ( [object isKindOfClass:[MFCountedColor class]]) {
        if ( self.count < object.count ) {
            return NSOrderedDescending;
        }else if (self.count == object.count) {
            return NSOrderedSame;
        }
    }
    return NSOrderedAscending;
}


@end

@interface MFExtractColor()
@property (nonatomic, strong, readwrite) UIColor *backgroundColor;
@property (nonatomic, strong, readwrite) UIColor *primaryColor;
@property (nonatomic, strong, readwrite) UIColor *secondaryColor;
@property (nonatomic, strong, readwrite) UIColor *detailColor;

@end

@implementation MFExtractColor

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        [self analyzeImage:image];
    }
    return self;
}

+ (void)extractColorFromImage:(UIImage *)image scaled:(CGSize)scaledSize completionHandler:(completionHandler)completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *newImage = [image scaledToSize:scaledSize];
        MFExtractColor *extractColor = [[MFExtractColor alloc] initWithImage:newImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(extractColor);
        });
    });
}

- (void)analyzeImage:(UIImage *)anImage {
    NSCountedSet *imageColors = nil;
    UIColor *backgroundColor = [self findEdgeColor:anImage imageColors:&imageColors];
    UIColor *primaryColor = nil;
    UIColor *secondaryColor = nil;
    UIColor *detailColor = nil;
    if (!backgroundColor) {
        backgroundColor = [UIColor whiteColor];
    }
    BOOL darkBackground = [backgroundColor mf_isDarkColor];
    [self findTextColors:imageColors primaryColor:&primaryColor secondaryColor:&secondaryColor detailColor:&detailColor backgroundColor:backgroundColor];
    
    if (!primaryColor) {
        if (darkBackground)
            primaryColor = [UIColor whiteColor];
        else
            primaryColor = [UIColor blackColor];
    }
    
    if (!secondaryColor) {
        if (darkBackground)
            secondaryColor = [UIColor whiteColor];
        else
            secondaryColor = [UIColor blackColor];
    }
    
    if (!detailColor) {
        if (darkBackground)
            detailColor = [UIColor whiteColor];
        else
            detailColor = [UIColor blackColor];
    }
    self.backgroundColor = backgroundColor;
    self.primaryColor = primaryColor;
    self.secondaryColor = secondaryColor;
    self.detailColor = detailColor;
}

typedef struct RGBAPixel {
    Byte red;
    Byte green;
    Byte blue;
    Byte alpha;
    
} RGBAPixel;

- (UIColor *)findEdgeColor:(UIImage *)image imageColors:(NSCountedSet**)colors {
 
    CGImageRef imageRep = image.CGImage;
    NSInteger width = CGImageGetWidth(imageRep);
    NSInteger height = CGImageGetHeight(imageRep);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, cs, kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bitmapContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    CGColorSpaceRelease(cs);
    NSCountedSet* imageColors = [[NSCountedSet alloc] initWithCapacity:width * height];
    NSCountedSet* edgeColors = [[NSCountedSet alloc] initWithCapacity:height];
    //优化：将bitmap取出作为变量传入，而不是每次循环重新创建。
    const RGBAPixel* pixels = (const RGBAPixel*)CGBitmapContextGetData(bitmapContext);
    for (NSUInteger y = 0; y < height; y++) {
        for (NSUInteger x = 0; x < width; x++) {
            const NSUInteger index = x + y * width;
            RGBAPixel pixel = pixels[index];
            UIColor* color = [[UIColor alloc] initWithRed:((CGFloat)pixel.red / 255.0f) green:((CGFloat)pixel.green / 255.0f) blue:((CGFloat)pixel.blue / 255.0f) alpha:1.0f];
            if (0 == x)
                [edgeColors addObject:color];
            [imageColors addObject:color];
        }
    }
    CGContextRelease(bitmapContext);
    *colors = imageColors;
    
    NSEnumerator *enumerator = [edgeColors objectEnumerator];
    UIColor *curColor = nil;
    NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[edgeColors count]];
    
    while (curColor = [enumerator nextObject]) {
        NSUInteger colorCount = [edgeColors countForObject:curColor];
        if (colorCount <= 2) // prevent using random colors, threshold should be based on input image size
            continue;
        MFCountedColor *container = [[MFCountedColor alloc] initWithColor:curColor count:colorCount];
        [sortedColors addObject:container];
    }
    [sortedColors sortUsingSelector:@selector(compare:)];
    MFCountedColor *proposedEdgeColor = nil;
    
    if ([sortedColors count] > 0) {
        proposedEdgeColor = [sortedColors objectAtIndex:0];
        
        if ([proposedEdgeColor.color mf_isBlackOrWhite] ) // want to choose color over black/white so we keep looking
        {
            for ( NSInteger i = 1; i < [sortedColors count]; i++ ) {
                MFCountedColor *nextProposedColor = [sortedColors objectAtIndex:i];
                
                if (((double)nextProposedColor.count / (double)proposedEdgeColor.count) > .4 ) // make sure the second choice color is 40% as common as the first choice
                {
                    if (![nextProposedColor.color mf_isBlackOrWhite]) {
                        proposedEdgeColor = nextProposedColor;
                        break;
                    }
                }else {
                    // reached color threshold less than 40% of the original proposed edge color so bail
                    break;
                }
            }
        }
    }
    
    return proposedEdgeColor.color;
}


- (void)findTextColors:(NSCountedSet*)colors primaryColor:(UIColor **)primaryColor secondaryColor:(UIColor **)secondaryColor detailColor:(UIColor **)detailColor backgroundColor:(UIColor *)backgroundColor {
    NSEnumerator *enumerator = [colors objectEnumerator];
    UIColor *curColor = nil;
    NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:[colors count]];
    BOOL findDarkTextColor = ![backgroundColor mf_isDarkColor];
    while ((curColor = [enumerator nextObject])) {
        curColor = [curColor mf_colorWithMinimumSaturation:.15];
        
        if ([curColor mf_isDarkColor] == findDarkTextColor) {
            NSUInteger colorCount = [colors countForObject:curColor];
            
            //if ( colorCount <= 2 ) // prevent using random colors, threshold should be based on input image size
            //    continue;
            
            MFCountedColor *container = [[MFCountedColor alloc] initWithColor:curColor count:colorCount];
            
            [sortedColors addObject:container];
        }
    }
    
    [sortedColors sortUsingSelector:@selector(compare:)];
    
    for (MFCountedColor *curContainer in sortedColors) {
        curColor = curContainer.color;
        if (!*primaryColor) {
            if ([curColor mf_isContrastingColor:backgroundColor])
                *primaryColor = curColor;
        }else if (!*secondaryColor) {
            if (![*primaryColor mf_isDistinct:curColor] || ![curColor mf_isContrastingColor:backgroundColor])
                continue;
            *secondaryColor = curColor;
        }else if (!*detailColor) {
            if (![*secondaryColor mf_isDistinct:curColor] || ![*primaryColor mf_isDistinct:curColor] || ![curColor mf_isContrastingColor:backgroundColor] )
                continue;
            *detailColor = curColor;
            break;
        }
    }
}


@end

