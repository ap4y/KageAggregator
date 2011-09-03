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
@synthesize anime = _anime;

static NSString* hostName = @"http://fansubs.ru/";

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

- (void)parseHtmlBody {
    if (_htmlBody) {
        NSArray* htmlArray = [RegexHelper arrayWithHtmlMatchesPattern:_htmlBody pattern:@"<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?</table>"];    
    
        for (NSString* htmlString in htmlArray) {                
            [self parseHtmlString:htmlString];
        } 
    }
}

- (void)parseHtmlHeader {    
    if (_htmlBody) {
        _anime.name = [RegexHelper stringWithHtmlTagContent:_htmlBody tag:@"title"];
        NSLog(@"anime name %@", _anime.name);
        NSString* imageTag = [RegexHelper stringWithHtmlMatchesPattern:_htmlBody pattern:@"<img.*?width=140.*?>"];
        NSString* imagePath = [RegexHelper stringWithHtmlMatchesPattern:imageTag pattern:@"src=.*width"];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:@"src=" withString:@""];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:@" width" withString:@""];    
        
        NSURL* imageUrl = [NSURL URLWithString:[hostName stringByAppendingPathComponent:imagePath]];
        _anime.image = [NSData dataWithContentsOfURL:imageUrl];
        NSLog(@"anime image size %i", _anime.image.length);
    }           
}

- (void)requestHtmlBody {
    _htmlBody = nil;
    NSError* err = nil;    
    //NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fansubs.ru/base.php?id=%i", _anime.baseId.integerValue]] encoding:NSWindowsCP1251StringEncoding error:&err];
    NSString* fileUrl = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"test.html"];
    NSString* html = [NSString stringWithContentsOfFile:fileUrl encoding:NSWindowsCP1251StringEncoding error:&err];
    
    if (err) {
        NSLog(@"getting string error %@", err.localizedDescription);     
        return;
    }
    else
        _htmlBody = [html stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
}

- (id)initWithAnime:(Anime*)anime {
    self = [super init];
    if (self) {
                
        if (!anime.objectID) {
            return nil;
        }
        
        _anime = anime;
        
        if (_anime.name == nil || anime.name.length == 0) {
                             
            [self requestHtmlBody];
            [self parseHtmlHeader];
        }
    }
    return self;
}

- (void)dealloc {
    [_anime release];
    [super dealloc];
}

@end
