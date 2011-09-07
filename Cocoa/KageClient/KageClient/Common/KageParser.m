//
//  KageParser.m
//  KageClient
//
//  Created by Arthur Evstifeev on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KageParser.h"
#import "RegexHelper.h"
#import "Subtitle.h"
#import "Group.h"
#import "AnimeCategory.h"

@implementation KageParser
@synthesize anime = _anime;

static NSString* hostName = @"http://fansubs.ru/";

- (void)parseHtmlString:(NSString*)htmlString groupString:(NSString*)groupString {
    //get srt objId
    NSString* srtIdString = [RegexHelper stringWithHtmlMatchesPattern:htmlString pattern:@"<input type=\"hidden\" name=\"srt\".*?>"];
    NSString* srtId = [RegexHelper stringWithHtmlMatchesPattern:srtIdString pattern:@"value=\"[0-9]*\""];
    srtId = [srtId stringByReplacingOccurrencesOfString:@"value=" withString:@""];
    srtId = [srtId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"srtId:%@", srtId);
    
    //split table to cell
    NSString* count = @"0";
    NSArray* cellArray = [RegexHelper arrayWithHtmlMatchesPattern:htmlString pattern:@"<td.*?>.*?</td>"];
    
    if (cellArray.count > 4 ) {
        
        NSString* countDescriptionCell = [RegexHelper stringWithHtmlMatchesPattern:[cellArray objectAtIndex:2] pattern:@"ТВ [0-9]*-[0-9]*"];
        count = [RegexHelper stringWithHtmlMatchesPattern:countDescriptionCell pattern:@"-[0-9]*"];
        count = [count stringByReplacingOccurrencesOfString:@"-" withString:@""];
        //NSLog(@"series translated %@", [count stringByReplacingOccurrencesOfString:@"-" withString:@""]);
        
        //NSString* formatCell = [cellArray objectAtIndex:3];
        //NSLog(@"%@", formatCell);
    }

    NSNumberFormatter* numFormat = [[[NSNumberFormatter alloc] init] autorelease];
    NSNumber* countNum = [numFormat numberFromString:count];
    NSLog(@"series count %@", countNum.stringValue);
    NSNumber* srtIdNum = [numFormat numberFromString:srtId];
    
    Subtitle* curSub = [_anime subtitleWithSrtId:srtIdNum];
    if (!curSub) {
        //new subtitle group
        Subtitle* newSub = [[[Subtitle alloc] initWithmanagedObjectContext:_anime.managedObjectContext] autorelease];        
        newSub.srtId = srtIdNum;
        newSub.seriesCount = countNum;    
        newSub.updated = [NSNumber numberWithBool:YES];
        
        //parse group information
        Group* fansubGroup = [[[Group alloc] initWithmanagedObjectContext:_anime.managedObjectContext] autorelease];
        
        NSArray* groupTables = [RegexHelper arrayWithHtmlMatchesPattern:groupString pattern:@"<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"row1\">.*?</table>"];
        
        fansubGroup.name = @"";
        for (NSString* nameStr in groupTables) {
            NSString* memberName = [RegexHelper stringWithHtmlTagContent:nameStr tag:@"b"];
            NSString* groupName = [RegexHelper stringWithHtmlMatchesPattern:nameStr pattern:@"web>.*?</a>]</td>"];
            groupName = [groupName stringByReplacingOccurrencesOfString:@"web>" withString:@""];
            groupName = [groupName stringByReplacingOccurrencesOfString:@"</a>]</td>" withString:@""];
            if (groupName && groupName.length > 0)
                groupName = [NSString stringWithFormat:@"[%@]", groupName];
            else
                groupName = @"";
            fansubGroup.name = [fansubGroup.name stringByAppendingString:[NSString stringWithFormat:@"%@%@\r\n", memberName, groupName]];
        }                    
        
        NSLog(@"fansubbers %@", fansubGroup.name);
        newSub.fansubGroup = fansubGroup;        
        [_anime addSubtitlesObject:newSub];
    }
    else {
        if (countNum.integerValue > curSub.seriesCount.integerValue) {
            curSub.seriesCount = countNum;
            curSub.updated = [NSNumber numberWithBool:YES];
        }
    }
}

- (void)parseHtmlBody {
    if (_htmlBody) {
        NSArray* htmlArray = [RegexHelper arrayWithRangesMatchesPattern:_htmlBody pattern:@"<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?</table>"];    
    
        for (int i = 0; i < htmlArray.count; i++) {
            NSTextCheckingResult* curResult = [htmlArray objectAtIndex:i];
            NSTextCheckingResult* nextResult = nil;
            if (i < htmlArray.count - 1) {
                nextResult = [htmlArray objectAtIndex:i + 1];
            }
            NSString* mainHtml = [_htmlBody substringWithRange: curResult.range];
            NSString* groupHtml = @"";
            
            if (nextResult) {
                groupHtml = [_htmlBody substringWithRange: NSMakeRange(curResult.range.location + curResult.range.length, nextResult.range.location - curResult.range.location - curResult.range.length)];
            }
            else {
                groupHtml = [_htmlBody substringWithRange: NSMakeRange(curResult.range.location + curResult.range.length, _htmlBody.length - curResult.range.location - curResult.range.length)];
            }        
            
            [self parseHtmlString:mainHtml groupString:groupHtml];
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
    }           
}

- (void)requestHtmlBody {
    _htmlBody = nil;
    NSError* err = nil;    
    //NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fansubs.ru/base.php?id=%i", _anime.baseId.integerValue]] encoding:NSWindowsCP1251StringEncoding error:&err];
    NSString* fileUrl = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"test.html"];
    NSString* html = [NSString stringWithContentsOfFile:fileUrl encoding:NSWindowsCP1251StringEncoding error:&err];
    
    if (err) {
        NSLog(@"getting string error %@", err.localizedDescription);     
        return;
    }
    else
        _htmlBody = [html stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
}

- (void)reloadData {
    [self parseHtmlBody];
}

- (id)initWithAnime:(Anime*)anime {
    self = [super init];
    if (self) {
                
        if (!anime.baseId) {
            return nil;
        }
        
        _anime = anime;
        [self requestHtmlBody];
        
        if (_anime.name == nil || anime.name.length == 0)                                      
            [self parseHtmlHeader];
    }
    return self;
}

- (void)dealloc {
    [_anime release];
    [super dealloc];
}

@end
