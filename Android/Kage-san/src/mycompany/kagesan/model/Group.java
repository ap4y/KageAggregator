package mycompany.kagesan.model;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "groups")
public class Group {
	
	@DatabaseField(id = true)
	public String name;
	//@DatabaseField(foreign = true)
	//public Subtitle subtitle;

	Group() {}
	
	public Group(String name) {
		this.name = name;
		//this.subtitle = subtitle;
	}
}
