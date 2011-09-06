//
//  StyleSheet.m
//  KageClient
//
//  Created by Arthur Evstifeev on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StyleSheet.h"
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];

@implementation StyleSheet

- (UIColor *)navigationBarTintColor {
    return RGB(145, 185, 50);
}

- (UIColor*)updatedCellBackgroundColor {
    return RGB(145, 185, 50);
}

- (UIColor *)backgroundColor {
    return RGB(230, 230, 230);
}

- (UIColor *)tablePlainBackgroundColor {
    return RGB(230, 230, 230);
}

- (UIColor *)tablePlainCellSeparatorColor {
    return RGB(145, 185, 50);
}

//- (UIFont*)font {
//    return [UIFont fontWithName:@"Segoe UI" size:13];
//}

- (UIFont *)tableFont {
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
        [fontNames release];
    }
    [familyNames release];
    return [UIFont fontWithName:@"SegoeUI-Bold" size:15];
}

- (UIFont *)tableSmallFont {
    return [UIFont fontWithName:@"SegoeUI-Bold" size:15];
}

- (UIFont *)messageFont {
    return [UIFont fontWithName:@"SegoeUI" size:15];
}

@end
