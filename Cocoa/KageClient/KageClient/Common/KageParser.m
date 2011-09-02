//
//  KageParser.m
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageParser.h"
#import "RegexHelper.h"

@implementation KageParser

- (void)parseHtmlString:(NSString*)htmlString {
    //get srt objId
    NSString* srtIdString = [RegexHelper stringWithHtmlMatchesPattern:htmlString pattern:@"<input type=\"hidden\" name=\"srt\".*?>"];
    NSString* srtId = [RegexHelper stringWithHtmlMatchesPattern:srtIdString pattern:@"value=\"[0-9]*\""];
    srtId = [srtId stringByReplacingOccurrencesOfString:@"value=" withString:@""];
    srtId = [srtId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"srtId:%@", srtId);
    
    //split table to cell
    NSArray* cellArray = [RegexHelper arrayWithHtmlMatchesPattern:htmlString pattern:@"<td.*?>.*?</td>"];
    
    if (cellArray.count > 4 ) {
        
        NSString* countDescriptionCell = [RegexHelper stringWithHtmlMatchesPattern:[cellArray objectAtIndex:2] pattern:@"ТВ [0-9]*-[0-9]*"];
        NSString* count = [RegexHelper stringWithHtmlMatchesPattern:countDescriptionCell pattern:@"-[0-9]*"];
        NSLog(@"series translated %@", [count stringByReplacingOccurrencesOfString:@"-" withString:@""]);
        
        //NSString* formatCell = [cellArray objectAtIndex:3];
        //NSLog(@"%@", formatCell);
    }      
}

- (void)parseHtml {
    NSString* cleanedHtml = [_htmlBody stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSArray* htmlArray = [RegexHelper arrayWithHtmlMatchesPattern:cleanedHtml pattern:@"<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?</table>"];    
    
    for (NSString* htmlString in htmlArray) {        
        if (_fansubGroup) {
            if ([htmlString rangeOfString:_fansubGroup].location != NSNotFound) {
                [self parseHtmlString:htmlString];
                return;
            }
        }
        else
            [self parseHtmlString:htmlString];
    }    
}

- (id)initWithContent:(NSString*)page fansubGroup:(NSString*)group {
    self = [super init];
    if (self) {
        _htmlBody = page;
        _fansubGroup = group;
        [self parseHtml];
    }
    return self;
}

- (id)initWithContent:(NSString*)page {
    return [self initWithContent:page fansubGroup:nil];
}

- (id)initWithURL:(NSURL*)page fansubGroup:(NSString*)group {
    NSError* err = nil;
    NSString* html = [NSString stringWithContentsOfURL:page encoding:NSWindowsCP1251StringEncoding error:&err];
    
    if (err)
        NSLog(@"getting url content error %@", err.localizedDescription);
    
    return [self initWithContent:html fansubGroup:group];
}

- (id)initWithURL:(NSURL*)page {
    return [self initWithURL:page fansubGroup:nil];
}

@end
