package mycompany.kagesan.common;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.regex.Matcher;

import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Group;
import mycompany.kagesan.model.Subtitle;

import android.util.Log;

public class KageParser {
	
	private final String LOG_TAG = getClass().getSimpleName();
	
	private static final String HOST_NAME = "http://fansubs.ru/";
	
	private Anime _anime = null;
	private String _htmlBody = null;
	
	public DatabaseHelper _helper;
	
	/*public KageParser(Anime anime) throws Exception {
		if (anime == null || anime.baseId == 0) {
			throw new Exception("Error creating parser");
		}
		
		_anime = anime;
		this.requestHtmlBody();
		
		if (_anime.name == null || _anime.name.length() == 0) {
			this.parseHtmlHeader();
		}
	}*/
	
	public KageParser(Anime anime, InputStream inputStream, DatabaseHelper helper) throws Exception {
		
		if (anime == null || anime.baseId == 0 || helper == null || inputStream == null) {
			throw new Exception("Error creating parser");
		}				
		
		_helper = helper;
		_anime = anime;
		this.requestHtmlBody(inputStream);
		
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
			Subtitle curSub = _helper.subtitleWithSrtId(_anime, srtIdNum);
			if (curSub == null) {
				//new subtitle group
				Subtitle newSub = new Subtitle(srtIdNum, countNum, true, _anime);								
				
				ArrayList<String> groupTables = RegexHelper.arrayWithHtmlMatchesPattern(groupString, "<table width=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"row1\">.*?</table>");
				String fansubGroupName = "";
				
				for (String nameStr : groupTables) {
					String memberName = RegexHelper.stringWithHtmlTagContent(nameStr, "b");
					String groupName = ""; 
					groupName = RegexHelper.stringWithHtmlMatchesPattern(nameStr, "web>.*?</a>]</td>");
					groupName = groupName.replace("web>", "");
					groupName = groupName.replace("</a>]</td>", "");
					if (groupName != null && groupName.length() != 0)
						groupName = "[" + groupName + "]";					
					else
						groupName = "";	
					
					fansubGroupName = fansubGroupName + memberName + groupName + "\r\n";									
				}
				
				Log.i(LOG_TAG, "fansubbers " + fansubGroupName);
				
				Group fansubGroup = new Group(fansubGroupName);
				fansubGroup = _helper.createGroup(fansubGroup);
				
				newSub.fansubgroup = fansubGroup;
				//_helper.createSubtitle(newSub);
				
				_helper.addSubtitle(_anime, newSub);
			}
			else if (countNum > curSub.seriesCount) {
				curSub.seriesCount = countNum;				
				curSub.updated = true;			
				_helper.getSubtitleDao().update(curSub);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}	    
	}
	
	private void parseHtmlBody() {
		if (_htmlBody != null) {
			Matcher htmlMatcher = RegexHelper.arrayWithRangesMatchesPattern(_htmlBody, "<table width=\"750\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">.*?</table>");
			
			String prevGroup = null;
			String curGroup = null;
			int prevEnd = 0; 
			while(htmlMatcher.find()) {
				curGroup = htmlMatcher.group();
				
				if (prevGroup != null) {
					String groupHtml = _htmlBody.substring(prevEnd, htmlMatcher.start());
					
					this.parseHtmlString(prevGroup, groupHtml);
				}
				
				prevEnd = htmlMatcher.end();
				prevGroup = curGroup;
			}
		}
	}

	private void parseHtmlHeader() {
		if (_htmlBody != null) {
			_anime.name = RegexHelper.stringWithHtmlTagContent(_htmlBody, "title");
			Log.i(LOG_TAG, "anime name " + _anime.name);
			String imageTag = RegexHelper.stringWithHtmlMatchesPattern(_htmlBody, "<img.*?width=140.*?>");
			String imagePath = RegexHelper.stringWithHtmlMatchesPattern(imageTag, "src=.*width");
			imagePath = imagePath.replace("src=", "");
			imagePath = imagePath.replace(" width", "");
			
			URL imageUrl;
			try {
				imageUrl = new URL(HOST_NAME + imagePath);
				_anime.imageData = this.getImageBytes(imageUrl);
			} catch (MalformedURLException e) {
				Log.i(LOG_TAG, "incorrect url string");
				e.printStackTrace();
			} catch (IOException e) {
				Log.i(LOG_TAG, "unable to get image bytes");
				e.printStackTrace();
			}	
			
			try {
				_helper.getAnimeDao().update(_anime);
			} catch (SQLException e) {
				Log.i(LOG_TAG, "unable to save anime");
				e.printStackTrace();
			}
		}
	}
	
	private byte[] getImageBytes(URL url) throws IOException {
		ByteArrayOutputStream bais = new ByteArrayOutputStream();
		InputStream is = null;
		try {
		  is = url.openStream();
		  byte[] byteChunk = new byte[4096];
		  int n;

		  while ( (n = is.read(byteChunk)) > 0 ) {
		    bais.write(byteChunk, 0, n);
		  }
		}
		catch (IOException e) {
			Log.i(LOG_TAG, "Failed while reading bytes from");
		  e.printStackTrace ();
		}
		finally {
		  if (is != null) { is.close(); }
		}
				
		return bais.toByteArray();
	}
	
	private String getHtmlContent(InputStream inputStream) throws IOException {			
		InputStreamReader streamReader = new InputStreamReader(inputStream, "Cp1251");
		BufferedReader in = new BufferedReader(streamReader);		
		StringBuilder inputLine = new StringBuilder();	
		
		try {
			int numRead = 0;
			char[] buf = new char[1024];
			while ((numRead = in.read(buf)) != -1) {
				inputLine.append(String.valueOf(buf, 0, numRead));		
				buf = new char[1024];
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally {
			if (inputStream != null) { in.close(); streamReader.close(); inputStream.close(); }
		}		
		
		return inputLine.toString();
	}
	
	private void requestHtmlBody(InputStream iStream) {
		_htmlBody = null;
		
		try {
			//URL url = new URL(HOST_NAME + "base.php?id=" + _anime.baseId);
			//String html = this.getHtmlContent(url.openStream());
			String html = this.getHtmlContent(iStream);						
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
