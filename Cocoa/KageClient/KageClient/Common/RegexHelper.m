//
//  RegexHelper.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegexHelper.h"
#import "RegexKitLite.h"

@implementation RegexHelper

+ (NSArray*)arrayWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern {
    if (!html || !pattern)
        return nil;
    
    return [html componentsMatchedByRegex:pattern];
}

+ (NSArray*)arrayWithRangesMatchesPattern:(NSString*)html pattern:(NSString*)pattern {
    if (!html || !pattern)
        return nil;

    NSMutableArray* result = [NSMutableArray array];
    NSRange prevRange = NSMakeRange(0, html.length);
    NSRange foundRange = [html rangeOfRegex:pattern inRange:prevRange];
    while (foundRange.location != NSNotFound) {
        [result addObject:[NSValue valueWithRange: foundRange]];
        prevRange = NSMakeRange(foundRange.location + foundRange.length, html.length - foundRange.location - foundRange.length);
        foundRange = [html rangeOfRegex:pattern inRange:prevRange];
    }
        
    return result;
}

+ (NSString*)stringWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern {
    if (!html || !pattern)
        return nil;
    
    return [html stringByMatching:pattern];    
}

+ (NSString*)stringWithHtmlTagContent:(NSString*)html tag:(NSString*)tag {
    if (!html || !tag)
        return nil;
        
    NSString* pattern = [NSString stringWithFormat:@"<%@>.*?</%@>", tag, tag];    
    
    NSString* result = [html stringByMatching:pattern];
    if (result != nil) {        
        result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", tag] withString:@""];
        result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</%@>", tag] withString:@""];
                
        return result;
    }
    else
        return nil;
}

@end
