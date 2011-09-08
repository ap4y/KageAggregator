package mycompany.kagesan.model;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.dao.ForeignCollection;
import com.j256.ormlite.stmt.PreparedQuery;
import com.j256.ormlite.stmt.QueryBuilder;
import com.j256.ormlite.support.ConnectionSource;
import com.j256.ormlite.table.TableUtils;

public class DatabaseHelper extends OrmLiteSqliteOpenHelper {

	private static final String DATABASE_NAME = "kagesan.db";
	private static final int DATABASE_VERSION = 1;

	private Dao<Anime, Integer> _animeDao = null;
	private Dao<Subtitle, Integer> _subtitleDao = null;

	public DatabaseHelper(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
	}

	@Override
	public void onCreate(SQLiteDatabase db, ConnectionSource connectionSource) {
		try {
			Log.i(DatabaseHelper.class.getName(), "onCreate");
			TableUtils.createTable(connectionSource, Anime.class);
		} catch (SQLException e) {
			Log.e(DatabaseHelper.class.getName(), "Can't create database", e);
			throw new RuntimeException(e);
		}
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, ConnectionSource connectionSource, int oldVersion, int newVersion) {
		try {
			Log.i(DatabaseHelper.class.getName(), "onUpgrade");
			TableUtils.dropTable(connectionSource, Anime.class, true);
			onCreate(db, connectionSource);
		} catch (SQLException e) {
			Log.e(DatabaseHelper.class.getName(), "Can't drop databases", e);
			throw new RuntimeException(e);
		}
	}

	public Dao<Anime, Integer> getAnimeDao() throws SQLException {
		if (_animeDao == null) {
			_animeDao = getDao(Anime.class);
		}
		return _animeDao;
	}
	
	public Dao<Subtitle, Integer> getSubtitleDao() throws SQLException {
		if (_subtitleDao == null) {
			_subtitleDao = getDao(Subtitle.class);
		}
		return _subtitleDao;
	}
	
	@Override
	public void close() {
		super.close();
		_animeDao = null;
		_subtitleDao = null;
	}
	
	public ArrayList<Anime> allAnime() throws SQLException {
		return (ArrayList<Anime>) _animeDao.queryForAll();
	}
	
	public Anime getAnime(int baseId) throws SQLException {
		return _animeDao.queryForId(baseId);
	}
	
	public boolean removeAnime(Anime animeToRemove) throws SQLException {
		return (_animeDao.delete(animeToRemove) == 1 ? true : false);
	}
	
	public void setIsWatched(Anime anime) {
		ForeignCollection<Subtitle> subtitles =  anime.subtitles;
		for (Subtitle subtitle : subtitles) {
			subtitle.updated = false;
		}		
	}
	
	public List<Subtitle> subtitlesBySeriesCount(Anime anime) throws SQLException {
		QueryBuilder<Subtitle, Integer> subtitleQuery = _subtitleDao.queryBuilder();
		subtitleQuery.where().eq("anime", anime);
		subtitleQuery.orderBy("seriesCount", true);
		PreparedQuery<Subtitle> prepQuery = subtitleQuery.prepare();
		
		return _subtitleDao.query(prepQuery);
	}
	
	public Subtitle subtitleWithSrtId(Anime anime, int srtId) throws SQLException {
		QueryBuilder<Subtitle, Integer> subtitleQuery = _subtitleDao.queryBuilder();
		subtitleQuery.where().eq("anime", anime).and().eq("srtId", srtId);
		PreparedQuery<Subtitle> prepQuery = subtitleQuery.prepare();
		List<Subtitle> result = _subtitleDao.query(prepQuery);
		
		return result.isEmpty() ? null : result.get(0); 
	}
	
	public List<Subtitle> subtitlesUpdated(Anime anime) throws SQLException {
		QueryBuilder<Subtitle, Integer> subtitleQuery = _subtitleDao.queryBuilder();
		subtitleQuery.where().eq("anime", anime).and().eq("updated", true);
		PreparedQuery<Subtitle> prepQuery = subtitleQuery.prepare();
		
		return _subtitleDao.query(prepQuery);
	}
	
	/*	
	+ (BOOL)addAnime:(NSNumber*)baseId managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	    
	    if ([self getAnime:baseId managedObjectContext:managedObjectContext]) {
	        return NO;
	    }            
	    
	    Anime* newAnime = [[Anime alloc] initWithmanagedObjectContext:managedObjectContext];  
	    newAnime.baseId = baseId;
	            
	    return [newAnime reloadAnime];
	}

	- (BOOL)reloadAnime {
	    KageParser* kageParser = [[[KageParser alloc] initWithAnime:self] autorelease];
	    
	    if (!kageParser)
	        return NO;

	    [kageParser reloadData];

	    return [CoreDataHelper save: self.managedObjectContext];
	}
*/
}
