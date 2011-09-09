package mycompany.kagesan.model;


import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "subtitles")
public class Subtitle {

	@DatabaseField(id = true)
	public int srtId;
	@DatabaseField
	public int seriesCount;
	@DatabaseField
	public boolean updated;
	@DatabaseField(foreign = true, columnName = "anime")
	public Anime anime;
	@DatabaseField(foreign = true)
	public Group fansubgroup;
	
	Subtitle() {}
	
	public Subtitle(int srtId, int seriesCount, boolean updated, Anime anime) {
		this.srtId =  srtId;
		this.seriesCount = seriesCount;
		this.updated = updated;
		this.anime = anime;
	}
}
