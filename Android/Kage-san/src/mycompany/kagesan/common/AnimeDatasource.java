package mycompany.kagesan.common;

import java.io.InputStream;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Hashtable;

import mycompany.kagesan.R;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;

import android.os.Handler;
import android.util.Log;

import com.j256.ormlite.android.apptools.OrmLiteBaseActivity;

public class AnimeDatasource extends OrmLiteBaseActivity<DatabaseHelper> {
	private final String LOG_TAG = getClass().getSimpleName();
	private final InputStream _iStream = getResources().openRawResource(R.raw.test); 
	
	private Hashtable<Integer, Boolean> _loadedFlags;
	private ArrayList<Anime> _items;
	private boolean _loading;
	private Handler _handler;
	
	private final AnimeDatasourceDelegate _delegate;	
	
	public AnimeDatasource(AnimeDatasourceDelegate delegate) {
		_delegate = delegate;
		_items = new ArrayList<Anime>();
		_loadedFlags = new Hashtable<Integer, Boolean>();
		this.loadItems();
	}
	
	public ArrayList<Anime> getItems() {
		return _items;
	}
	
	public void loadItems() {
		_loading = true;

		_items.removeAll(_items);
		
		ArrayList<Anime> viewsWithNew = new ArrayList<Anime>();
		ArrayList<Anime> viewsWithOutNew = new ArrayList<Anime>();
		try {
			for (Anime anime : getHelper().allAnime()) {
				if (getHelper().subtitlesUpdated(anime).size() > 0)
					viewsWithNew.add(anime);
				else
					viewsWithOutNew.add(anime);
			}
			
			_items.addAll(viewsWithNew);
			_items.addAll(viewsWithOutNew);
			
			for (Anime anime : _items) {
				_loadedFlags.put(anime.baseId, false);
			}
			
			for (final Anime anime : _items) {
				Runnable runnable = new Runnable() {
					
					public void run() {
						try {
							Anime threadAnime = getHelper().getAnime(anime.baseId);
							getHelper().reloadAnime(threadAnime, _iStream);
							
							synchronized (_loadedFlags) {
								_loadedFlags.put(anime.baseId, true);
								
								boolean isLoadingCheck = false;
								for (boolean value : _loadedFlags.values()) {
									if (value) {
										isLoadingCheck = true;
										break;
									}
								}
								
								_loading = isLoadingCheck;
								if (!_loading) {
									_handler.post(new Runnable() {
										
										public void run() {
											_delegate.animeDatasourceDidChanged();
										}
									});									
								}
							}
						} catch (SQLException e) {
							Log.i(LOG_TAG, "unabled to reload anime data: " + anime.baseId);
							e.printStackTrace();
						}
					}
				};
				new Thread(runnable).run();
			}
			
		} catch (SQLException e) {
			Log.i(LOG_TAG, "unabled to reload anime list");
			e.printStackTrace();
		}
	}
	
	public void removeAnime(Anime anime) {
		try {
			if (getHelper().removeAnime(anime)) {
				_items.remove(anime);
				_delegate.animeDatasourceDidChanged();
			}
		} catch (SQLException e) {
			Log.i(LOG_TAG, "unabled to remove anime " + anime.name);
			e.printStackTrace();
		}
	}
	
	public void addAnime(final int objId) {
		new Thread(new Runnable() {
			
			public void run() {
				try {
					if (getHelper().addAnime(objId, _iStream)) {
						Anime anime = getHelper().getAnime(objId);
						_items.add(anime);
						_delegate.animeDatasourceDidChanged();
					}
				} catch (SQLException e) {
					Log.i(LOG_TAG, "unabled to add anime " + objId);
					e.printStackTrace();
				}				
			}
		}).run();
	}	
}
