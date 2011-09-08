package mycompany.kagesan.model;

import com.j256.ormlite.dao.ForeignCollection;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.field.ForeignCollectionField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "animes")
public class Anime {

	@DatabaseField(id = true)
	public int baseId;
	@DatabaseField
	public String name;
	@DatabaseField
	public byte[] imageData;
	@ForeignCollectionField(eager = false, columnName = "subtitles")
	public ForeignCollection<Subtitle> subtitles;
	
	Anime() { 
		
	}
	
	public void addSubtitle (Subtitle subtitle) {
		subtitles.add(subtitle);
	}
}
