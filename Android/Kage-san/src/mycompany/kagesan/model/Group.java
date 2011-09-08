package mycompany.kagesan.model;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

@DatabaseTable(tableName = "groups")
public class Group {
	
	@DatabaseField(id = true)
	String name;
	@DatabaseField(foreign = true)
	Subtitle subtitle;

	Group() {}
}
