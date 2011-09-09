package mycompany.kagesan.common;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class RegexHelper {

	public static Matcher arrayWithRangesMatchesPattern(String html, String pattern) {
		if (html == null || pattern == null) {
			return null;
		}
		
		Pattern regexPattern = Pattern.compile(pattern, Pattern.CASE_INSENSITIVE & Pattern.MULTILINE);
		Matcher matcher = regexPattern.matcher(html);
		
		return matcher;
	}
	
	public static ArrayList<String> arrayWithHtmlMatchesPattern(String html, String pattern) {
		if (html == null || pattern == null) {
			return null;
		}
		
		Pattern regexPattern = Pattern.compile(pattern, Pattern.CASE_INSENSITIVE & Pattern.MULTILINE);
		Matcher matcher = regexPattern.matcher(html);
		
		ArrayList<String> result = new ArrayList<String>();
		while(matcher.find()) {
			result.add(matcher.group());
		}
		
		return result;
	}

	public static String stringWithHtmlMatchesPattern(String html, String pattern) {
		if (html == null || pattern == null) {
			return "";
		}
		
		Pattern regexPattern = Pattern.compile(pattern, Pattern.CASE_INSENSITIVE & Pattern.MULTILINE);
		Matcher matcher = regexPattern.matcher(html);
		
		if (matcher.find()) {
			return matcher.group();
		}		
		else
			return "";
	}
	
	public static String stringWithHtmlTagContent(String html, String tag) {
		if (html == null || tag == null) {
			return "";
		}
		
		String pattern = "<" + tag + ">.*?</" + tag + ">"; 
		Pattern regexPattern = Pattern.compile(pattern, Pattern.CASE_INSENSITIVE & Pattern.MULTILINE);
		Matcher matcher = regexPattern.matcher(html);
		
		if (matcher.find()) {
			String result = matcher.group();
			result = result.replace("<" + tag + ">", "");
			result = result.replace("</" + tag + ">", "");
			return result;					
		}		
		else
			return "";
	}
}
