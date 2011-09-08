package mycompany.kagesan.model;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "subtitles")
public class Subtitle {

	@DatabaseField(id = true)
	int srtId;
	@DatabaseField
	int seriesCount;
	@DatabaseField
	boolean updated;
	@DatabaseField(foreign = true, columnName = "anime")
	Anime anime;
	@DatabaseField(foreign = true)
	Group fansubgroup;
	
	Subtitle() {}
}
