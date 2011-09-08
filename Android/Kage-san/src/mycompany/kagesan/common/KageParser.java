package mycompany.kagesan.common;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;

import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Group;
import mycompany.kagesan.model.Subtitle;

import com.j256.ormlite.android.apptools.OrmLiteBaseActivity;

import android.util.Log;

public class KageParser extends OrmLiteBaseActivity<DatabaseHelper> {
	
	private final String LOG_TAG = getClass().getSimpleName();
	
	private static final String HOST_NAME = "http://fansubs.ru/";
	
	private Anime _anime = null;
	private String _htmlBody = null;
	
	public KageParser(Anime anime) throws Exception {
		if (anime == null || anime.baseId == 0) {
			throw new Exception("Error creating parser");
		}
		
		_anime = anime;
		this.requestHtmlBody();
		
		if (_anime.name == null || _anime.name.length() == 0) {
			this.parseHtmlHeader();
		}
	}
	
	private void parseHtmlString(String htmlString, String groupString) {
		//get srtId
	    String srtIdString = RegexHelper.stringWithHtmlMatchesPattern(htmlString, "<input type=\"hidden\" name=\"srt\".*?>"); 
	    String srtId = RegexHelper.stringWithHtmlMatchesPattern(srtIdString, "value=\"[0-9]*\"");
	    srtId = srtId.replace("value=", "");
	    srtId = srtId.replace("\"", "");
	    Log.i(LOG_TAG, "srtId:" + srtId);
	    	    	 
	    //split table to cell
	    String count = "0";
	    ArrayList<String> cellArray = RegexHelper.arrayWithHtmlMatchesPattern(htmlString, "<td.*?>.*?</td>");

	    if (cellArray.size() > 4) {
	    	String countDescriptionCell = RegexHelper.stringWithHtmlMatchesPattern(cellArray.get(2), "ТВ [0-9]*-[0-9]*");
	    	count = RegexHelper.stringWithHtmlMatchesPattern(countDescriptionCell, "-[0-9]*");
	    	count = count.replace("-", "");
		}
	    
	    int countNum = Integer.parseInt(count);
	    int srtIdNum = Integer.parseInt(srtId);
	    try {
			Subtitle curSub = getHelper().subtitleWithSrtId(_anime, srtIdNum);
			if (curSub != null) {
				//new subtitle group
				Subtitle newSub = new Subtitle(srtIdNum, countNum, true, _anime);
				
				ArrayList<String> groupTables = RegexHelper.arrayWithHtmlMatchesPattern(groupString, "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"row1\">.*?</table>");
				String fansubGroupName = "";
				
				for (String nameStr : groupTables) {
					String memberName = RegexHelper.stringWithHtmlTagContent(nameStr, "b");
					String groupName = RegexHelper.stringWithHtmlMatchesPattern(nameStr, "web>.*?</a>]</td>");
					groupName = groupName.replace("web>", "");
					groupName = groupName.replace("</a>]</td>", "");
					if (groupName != null && groupName.length() != 0)
						groupName = "[" + groupName + "]";					
					else
						groupName = "";	
					
					fansubGroupName = fansubGroupName + memberName + groupName + "\r\n";									
				}
				
				Log.i(LOG_TAG, "fansubbers " + fansubGroupName);
				
				Group fansubGroup = new Group(fansubGroupName, newSub);
				newSub.fansubgroup = fansubGroup;
				_anime.addSubtitle(newSub);
			}
			else if (countNum > curSub.seriesCount) {
				curSub.seriesCount = countNum;				
				curSub.updated = true;				
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}	    
	}
	
	private void parseHtmlBody() {
		this.parseHtmlString("", "");
	}
/*
 
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
 */
	private void parseHtmlHeader() {
		if (_htmlBody != null) {
			
		}
	}
	
	private String getHtmlContent(URL url) throws IOException {
		BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));
		String inputLine;

		while ((inputLine = in.readLine()) != null) {
		}
		in.close();
		
		return inputLine;
	}
	
	private void requestHtmlBody() {
		_htmlBody = null;
		URL url;
		try {
			url = new URL(HOST_NAME + "base.php?id=" + _anime.baseId);
			String html = this.getHtmlContent(url);
			//NSString* fileUrl = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"test.html"];
		    //NSString* html = [NSString stringWithContentsOfFile:fileUrl encoding:NSWindowsCP1251StringEncoding error:&err];
			
			_htmlBody = html.replace("\r\n", "");
		} catch (MalformedURLException e) {
			Log.i(LOG_TAG, "getting string error " + e.getLocalizedMessage());
		} catch (IOException e) {
			Log.i(LOG_TAG, "getting string error " + e.getLocalizedMessage());
		}				
	}
	
	public void reloadData() {
		this.parseHtmlBody();
	}		
}
