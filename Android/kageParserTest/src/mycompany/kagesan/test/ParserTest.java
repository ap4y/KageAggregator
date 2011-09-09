package mycompany.kagesan.test;

import java.io.InputStream;

import mycompany.kagesan.common.KageParser;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import android.test.AndroidTestCase;
import android.util.Log;

public class ParserTest extends AndroidTestCase {

	public void testKageParserWithNewAnime() {
        Anime anime = new Anime();
		anime.baseId = 3302;
		try {			
			InputStream inputStream = mContext.getResources().openRawResource(123);
			KageParser kageParser = new KageParser(anime, inputStream);	
			DatabaseHelper newHelper = new DatabaseHelper(mContext);
			kageParser.helper = newHelper;
			kageParser.reloadData();
			
			assertFalse("Incorrect name of the anime or error during parsing", anime.name.equals("Ao no Exorcist"));
			assertFalse("Incorrect quantity of subtitles", anime.subtitles.size() == 7);
		} catch (Exception e) {
			Log.i("KageParserTest", "Kage parser can`t be initialized");
			e.printStackTrace();
		}
	}
}
