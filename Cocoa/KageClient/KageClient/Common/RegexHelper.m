//
//  RegexHelper.m
//  KageClient
//
//  Created by Arthur Evstifeev on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegexHelper.h"

@implementation RegexHelper

- (NSString*)parseXmlParam:(NSString*)paramName paramContent:(NSString*)paramContent {
    NSError* err;
    
    NSString* pattern = [NSString stringWithFormat:@"<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?<%@", paramName, paramName];    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive & NSRegularExpressionDotMatchesLineSeparators) error:&err];
    
    NSArray* paramArray = [regex matchesInString:paramContent options:NSMatchingCompleted range:NSMakeRange(0, paramContent.length)];
    
    NSString *result = @"";
    if (paramArray.count > 0) {
        NSTextCheckingResult* paramArrayResult = [paramArray objectAtIndex:0];
        result = [paramContent substringWithRange:paramArrayResult.range];
        //result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", paramName] withString:@""];
        //result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"</%@>", paramName] withString:@""];            
    }    
    else
        return nil;
    
    return result;
}

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

@end
