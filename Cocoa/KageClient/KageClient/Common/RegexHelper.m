//
//  RegexHelper.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegexHelper.h"

@implementation RegexHelper

+ (NSArray*)arrayWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern {
    NSError* err = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive & NSRegularExpressionDotMatchesLineSeparators) error:&err];
    
    if (err) {
        NSLog(@"regex error: %@", err.localizedDescription);
        return nil;
    }
    
    NSArray* paramArray = [regex matchesInString:html options:NSMatchingCompleted range:NSMakeRange(0, html.length)];
    
    NSMutableArray* result = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSTextCheckingResult* paramArrayResult in paramArray) {
        [result addObject:[html substringWithRange:paramArrayResult.range]];
    }
    
    return result;
}

+ (NSString*)stringWithHtmlMatchesPattern:(NSString*)html pattern:(NSString*)pattern {
    NSError* err = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive & NSRegularExpressionDotMatchesLineSeparators) error:&err];
    
    if (err) {
        NSLog(@"regex error: %@", err.localizedDescription);
        return nil;
    }
    
    NSArray* paramArray = [regex matchesInString:html options:NSMatchingCompleted range:NSMakeRange(0, html.length)];
    
    if (paramArray.count > 0) {
        return [html substringWithRange:((NSTextCheckingResult*)[paramArray objectAtIndex:0]).range];
    }
    else
        return nil;
}

+ (NSString*)stringWithHtmlTagContent:(NSString*)html tag:(NSString*)tag {
    NSError* err;
    
    NSString* pattern = [NSString stringWithFormat:@"<%@>.*?</%@>", tag, tag];
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive & NSRegularExpressionDotMatchesLineSeparators) error:&err];
    
    if (err) {
        NSLog(@"regex error: %@", err.localizedDescription);
        return nil;
    }
    
    NSArray* paramArray = [regex matchesInString:html options:NSMatchingCompleted range:NSMakeRange(0, html.length)];
    
    NSString *result = @"";
    if (paramArray.count > 0) {
        NSTextCheckingResult* paramArrayResult = [paramArray objectAtIndex:0];
        result = [html substringWithRange:paramArrayResult.range];
        result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", tag] withString:@""];
        result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</%@>", tag] withString:@""];            
    }    
    else
        return nil;
    
    return result;
}

@end
