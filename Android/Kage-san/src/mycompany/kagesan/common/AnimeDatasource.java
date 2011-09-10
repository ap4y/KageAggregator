package mycompany.kagesan.common;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import mycompany.kagesan.R;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Subtitle;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TableLayout;
import android.widget.TextView;

public class AnimeDatasource {
	private final String LOG_TAG = getClass().getSimpleName();
	
	private Hashtable<Integer, Boolean> _loadedFlags;
	private ArrayList<Anime> _items;
	private boolean _loading;
	private Handler _handler;
	private DatabaseHelper _helper; 
	private Context _context;
	
	private final AnimeDatasourceDelegate _delegate;	
	
	public AnimeDatasource(AnimeDatasourceDelegate delegate, Context context) {		
		_delegate = delegate;
		_items = new ArrayList<Anime>();
		_loadedFlags = new Hashtable<Integer, Boolean>();
		_helper = new DatabaseHelper(context);
		_context = context;		
		_handler = new Handler();
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
			for (Anime anime : _helper.allAnime()) {
				if (_helper.subtitlesUpdated(anime).size() > 0)
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
							Anime threadAnime = _helper.getAnime(anime.baseId);
							_helper.reloadAnime(threadAnime, _context.getResources().openRawResource(R.raw.test));
							
							//synchronized (_loadedFlags) {							
								_loadedFlags.put(anime.baseId, true);
								
								boolean isLoadingCheck = false;
								for (boolean value : _loadedFlags.values()) {
									if (!value) {
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
							//}
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
			if (_helper.removeAnime(anime)) {
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
					if (_helper.addAnime(objId, _context.getResources().openRawResource(R.raw.test))) {
						Anime anime = _helper.getAnime(objId);
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
	
	public void infiltrateAnimeView(TableLayout animeTable) {
		for (Anime anime : _items) {    
			try {
	    		LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	        	View animeView = inflater.inflate(R.layout.animeview, animeTable);
	        	        	
	        	TextView animeName = (TextView) animeView.findViewById(R.id.animeNameText);
	        	animeName.setText(anime.name);
	        	
	        	ImageView animeImage = (ImageView) animeView.findViewById(R.id.animeImageView);
	        	animeImage.setImageBitmap(BitmapFactory.decodeByteArray(anime.imageData, 0, anime.imageData.length));	
	        	
	        	TextView subCountText = (TextView) animeView.findViewById(R.id.subCountText);
	        	Subtitle maxSub = _helper.subtitlesWithMaxCount(anime);	        	
	        	int maxSeries = maxSub == null ? 0 : maxSub.seriesCount;
	        	subCountText.setText("переведено " + maxSeries);
	        	
	        	List<Subtitle> updatedSubtitles = _helper.subtitlesUpdated(anime);
	        	TextView newCountText = (TextView) animeView.findViewById(R.id.newCountText);
	        	if (updatedSubtitles.size() == 1) 
	        		newCountText.setText("" + updatedSubtitles.size() + " новая");
	        	else
	        		newCountText.setText("" + updatedSubtitles.size() + " новых");	        	
			} catch (Exception e) {
				e.printStackTrace();
			}
		} 		
	}
}
