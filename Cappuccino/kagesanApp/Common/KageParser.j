@import "RegexHelper.j"
@import "../Model/Anime.j"
@import "../Model/Subtitle.j"
@import "../Model/Group.j"

@implementation KageParser : CPObject {
    CPString _htmlBody;
    Anime _anime;
}

- (void)parseHtmlString:(CPString)htmlString groupString:(CPString)groupString {    
    //get srt objId
    var srtIdString = [RegexHelper stringWithHtmlMatchesPattern:htmlString pattern:"<input type=\"hidden\" name=\"srt\".*?>"];    
    var srtId = [RegexHelper stringWithHtmlMatchesPattern:srtIdString pattern:"value=\"[0-9]*\""];
    srtId = [srtId stringByReplacingOccurrencesOfString:"value=" withString:""];
    srtId = [srtId stringByReplacingOccurrencesOfString:"\"" withString:""];
    CPLog("srtId: " + srtId);
    
    //split table to cell
    var count = "0";
    var cellArray = [RegexHelper arrayWithHtmlMatchesPattern:htmlString pattern:"<td.*?>.*?</td>"];
    
    if ([cellArray count] > 4 ) {
        
        var countDescriptionCell = [RegexHelper stringWithHtmlMatchesPattern:[cellArray objectAtIndex:2] pattern:"ТВ [0-9]*-[0-9]*"];
        count = [RegexHelper stringWithHtmlMatchesPattern:countDescriptionCell pattern:"-[0-9]*"];
        count = [count stringByReplacingOccurrencesOfString:"-" withString:""];
        CPLog("series translated " + count);
    }
    
    var numberFormatter = [[CPNumberFormatter alloc] init];
    var srtIdNum = [numberFormatter numberFromString: srtId];
    var countNum = [numberFormatter numberFromString: count];
    
    var curSub = [_anime subtitleWithSrtId: srtIdNum];
    if (!curSub) {
        //new subtitle group
        var newSub = [[Subtitle alloc] init];        
        //newSub.anime = _anime;
        newSub.srtId = srtIdNum;
        newSub.seriesCount = countNum;    
        newSub.updated = [CPNumber numberWithBool:YES];
        
        CPLog("newSub: " + newSub.srtId + "," + newSub.seriesCount + "," + newSub.updated);
        //parse group information
        //var fansubGroup = [[Group alloc] init];
        //fansubGroup.subtitle = newSub;
        
        var groupTables = [RegexHelper arrayWithHtmlMatchesPattern:groupString pattern:"<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"row1\">.*?</table>"];        
        
        newSub.name = @"";
        for (var i = 0; i < [groupTables count]; i++) {
            var nameStr = [groupTables objectAtIndex: i];
            
            var memberName = [RegexHelper stringWithHtmlTagContent:nameStr tag:"b"];            
            var groupName = [RegexHelper stringWithHtmlMatchesPattern:nameStr pattern:"web>.*?</a>]</td>"];            
            groupName = [groupName stringByReplacingOccurrencesOfString:"web>" withString:""];
            groupName = [groupName stringByReplacingOccurrencesOfString:"</a>]</td>" withString:""];
            if (groupName && [groupName length] > 0)
                groupName = [CPString stringWithFormat:"[%@]", groupName];
            else
                groupName = @"";
            newSub.name = [newSub.name stringByAppendingString:[CPString stringWithFormat:@"%@%@\r\n", memberName, groupName]];
        }                    
        
        CPLog(@"fansubbers " + newSub.name);
        //newSub.fansubGroup = fansubGroup;  
        
        [_anime.subtitles addObject:newSub];            
    }
    else {
        if (countNum.integerValue > curSub.seriesCount.integerValue) {
            curSub.seriesCount = countNum;
            curSub.updated = [CPNumber numberWithBool:YES];    
        }
    }    

    //CPLog("anime " + _anime.name + " subtitle count " + [_anime.subtitles count]);
    //CPLog("Should call save!!!");
}

- (void)parseHtmlBody {
    if (_htmlBody) {
        var htmlArray = [RegexHelper arrayWithRangesMatchesPattern:_htmlBody pattern:"<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?</table>"];    
        
        var i = 0;
        while (i < [htmlArray count]) {
            var mainHtml = htmlArray[i++];
            var groupHtml = htmlArray[i++];
                        
            //CPLog("mainHtml: " + mainHtml);
            //CPLog("groupHtml: " + groupHtml);
            [self parseHtmlString: [CPString stringWithString:mainHtml] groupString: [CPString stringWithString:groupHtml]];
        }
    }
}

- (void)parseHtmlHeader {    
    if (_htmlBody) {
        var hostName = @"http://fansubs.ru/";
        
        _anime.name = [RegexHelper stringWithHtmlTagContent:_htmlBody tag:"title"];
        CPLog("anime name " + _anime.name);
        var imageTag = [RegexHelper stringWithHtmlMatchesPattern:_htmlBody pattern:"<img.*?width=140.*?>"];
        var imagePath = [RegexHelper stringWithHtmlMatchesPattern:imageTag pattern:"src=.*width"];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:"src=" withString:""];
        imagePath = [imagePath stringByReplacingOccurrencesOfString:" width" withString:""];    
        
        imagePath = hostName + imagePath;
        CPLog("image path " + imagePath);
        _anime.image = imagePath;
        //CPLog("anime image size " + [_anime.image length]);
    }           
}

- (void)requestHtmlBody {
    _htmlBody = nil;
    //NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fansubs.ru/base.php?id=%i", _anime.baseId.integerValue]] encoding:NSWindowsCP1251StringEncoding error:&err];
    var request = [CPURLRequest requestWithURL: [CPURL URLWithString: "file:///Users/ap4y/github/KageAggregator/test.html"]];
    var result = [CPURLConnection sendSynchronousRequest:request returningResponse:nil]; 
    var html = [result rawString];
    
    _htmlBody = [html stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    CPLog("Requested body: result length " + _htmlBody.length);
}

- (void)reloadData {
    [self parseHtmlBody];
}

- (id)initWithAnime:(Anime*)anime {
    self = [super init];
    if (self) {
        
        if (anime == nil || anime.baseId == nil) {
            CPLog("unable to create anime");
            return nil;
        }
        
        _anime = anime;
        CPLog("Requesting body");
        [self requestHtmlBody];
        
        if (_anime.name == nil || anime.name.length == 0)    
            CPLog("Parsing header");
            [self parseHtmlHeader];
    }
    return self;
}

@end
