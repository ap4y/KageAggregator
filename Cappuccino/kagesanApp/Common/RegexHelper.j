@implementation RegexHelper : CPObject

+ (CPArray)arrayWithHtmlMatchesPattern:(CPString)html pattern:(CPString)pattern {
    if (!html || !pattern)
        return nil;
    
    var regExp = new RegExp(pattern, "gi");

    return html.match(regExp);
}

+ (CPArray)arrayWithRangesMatchesPattern:(CPString)html pattern:(CPString)pattern {
    if (!html || !pattern)
        return nil;
    
    var regExp = new RegExp(pattern, "gi");

    var curVal = null;
    var result = [[CPMutableArray alloc] init];
    
    var prevIndex = null;
    while ((curVal = regExp.exec(html)) != null) {
        if (prevIndex != null) {
            var groupHtml = [html substringWithRange: CPMakeRange(prevIndex, curVal.index - prevIndex)];
            [result addObject: groupHtml];
            //CPLog("groupHtml: " + groupHtml);
        }        

        [result addObject: curVal];
        //CPLog("mainHtml: " + curVal);
        prevIndex = regExp.lastIndex;        
    }    
    
    var groupHtml = [html substringWithRange: CPMakeRange(prevIndex, html.length - prevIndex)];
    [result addObject: groupHtml];
    //CPLog("groupHtml: " + groupHtml);
        
    return result;    
}

+ (CPString)stringWithHtmlMatchesPattern:(CPString)html pattern:(CPString)pattern {
    if (!html || !pattern)
        return nil;
    
    var regExp = new RegExp(pattern);        

    var matches = null;
    matches = html.match(regExp);
    
    //CPLog("pattern: " + regExp);
    //CPLog("htmlString: " + html);
    //CPLog("matches: " + matches);
    
    if (matches != nil &&  matches.length > 0)
        return matches[0];
    else
        return nil;
}

+ (CPString)stringWithHtmlTagContent:(CPString)html tag:(CPString)tag {
    if (!html || !tag)
        return nil;
    
    var pattern = "<" + tag + ">.*?</" + tag + ">";
    var regExp = new RegExp(pattern);
    var matches = html.match(regExp);    
    
    //CPLog("pattern: " + regExp);
    //CPLog("htmlString: " + html);
    //CPLog("matches: " + matches);
    
    var result = @"";
    if (matches != nil || matches.length > 0) {        
        result = matches[0];
        result = [result stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"<%@>", tag] withString:""];
        result = [result stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"</%@>", tag] withString:""];            
    }    
    else
        return nil;
    
    return result;
}

@end
