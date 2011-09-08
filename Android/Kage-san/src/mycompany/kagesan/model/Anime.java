package mycompany.kagesan.model;

import com.j256.ormlite.dao.ForeignCollection;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.field.ForeignCollectionField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "animes")
public class Anime {

	@DatabaseField(id = true)
	int baseId;
	@DatabaseField
	String name;
	@DatabaseField
	byte[] imageData;
	@ForeignCollectionField(eager = false, columnName = "subtitles")
    ForeignCollection<Subtitle> subtitles;
	
	Anime() { 
		
	}
}
