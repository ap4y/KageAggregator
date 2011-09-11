package mycompany.kagesan.common;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import mycompany.kagesan.KagesanActivity;
import mycompany.kagesan.R;
import mycompany.kagesan.SubtitlesListActivity;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Subtitle;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageButton;
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
	
	private InputStream getInputStream(int baseId) {		
		try {
			URL url = new URL("http://fansubs.ru/base.php?id=" + baseId);
			return url.openStream();				
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
					
		//return _context.getResources().openRawResource(R.raw.test);
	}
	
	public void loadItems() {
		_loading = true;

		_items.removeAll(_items);
		
		try {			
			_items.addAll(_helper.allAnime());
			
			for (Anime anime : _items) {
				_loadedFlags.put(anime.baseId, false);
			}
			
			for (final Anime anime : _items) {
				Runnable runnable = new Runnable() {
					
					public void run() {
						try {
							Anime threadAnime = _helper.getAnime(anime.baseId);
							_helper.reloadAnime(threadAnime, getInputStream(anime.baseId));
							
							synchronized (_loadedFlags) {							
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
											try {
												_items.removeAll(_items);
												
												ArrayList<Anime> viewsWithNew = new ArrayList<Anime>();
												ArrayList<Anime> viewsWithOutNew = new ArrayList<Anime>();
												
												for (Anime anime : _helper.allAnime()) {
													if (_helper.subtitlesUpdated(anime).size() > 0)
														viewsWithNew.add(anime);
													else
														viewsWithOutNew.add(anime);
												}
												
												_items.addAll(viewsWithNew);
												_items.addAll(viewsWithOutNew);
												
											} catch (SQLException e) {
												Log.i(LOG_TAG, "Unable to reload anime");
												e.printStackTrace();
											}																		
											
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
					if (_helper.addAnime(objId, getInputStream(objId))) {
						Anime anime = _helper.getAnime(objId);
						_items.add(0, anime);
						_delegate.animeDatasourceDidChanged();
					}
				} catch (SQLException e) {
					Log.i(LOG_TAG, "unabled to add anime " + objId);
					e.printStackTrace();
				}				
			}
		}).run();
	}
	
	private void doNotification(Anime anime, Subtitle subtitle) {

		final int NOTIF_ID = subtitle.srtId;  
			
		NotificationManager notifManager = (NotificationManager) _context.getSystemService(Context.NOTIFICATION_SERVICE);  
		Notification note = new Notification(R.drawable.icon, "Новая серия", System.currentTimeMillis());  
		note.flags = Notification.FLAG_AUTO_CANCEL;
		
		PendingIntent intent = PendingIntent.getActivity(_context, 0, new Intent(_context, KagesanActivity.class), 0);  		  
		   		  		   		 			
		CharSequence contentText = subtitle.seriesCount + " серия от " + subtitle.fansubgroup.name;
		 
		note.setLatestEventInfo(_context, anime.name, contentText, intent);
		notifManager.notify(NOTIF_ID, note);
	}
	
	public void infiltrateAnimeView(TableLayout animeTable) {
		Typeface segoe = Typeface.createFromAsset(_context.getAssets(), "fonts/segoeui.TTF");
		Typeface segoeBold = Typeface.createFromAsset(_context.getAssets(), "fonts/seguibd.ttf");
		
		for (final Anime anime : _items) {    
			try {
				View animeView = View.inflate(_context, R.layout.animeview, null);	        	
	        	        	
	        	TextView animeName = (TextView) animeView.findViewById(R.id.animeNameText);
	        	animeName.setText(anime.name);
	        	animeName.setTypeface(segoeBold);
	        	
	        	ImageView animeImage = (ImageView) animeView.findViewById(R.id.animeImageView);
	        	animeImage.setImageBitmap(BitmapFactory.decodeByteArray(anime.imageData, 0, anime.imageData.length));	
	        	
	        	TextView subCountText = (TextView) animeView.findViewById(R.id.subCountText);
	        	Subtitle maxSub = _helper.subtitlesWithMaxCount(anime);	        	
	        	int maxSeries = maxSub == null ? 0 : maxSub.seriesCount;
	        	subCountText.setText("переведено " + maxSeries);
	        	subCountText.setTypeface(segoe);
	        	
	        	List<Subtitle> updatedSubtitles = _helper.subtitlesUpdated(anime);
	        	for (Subtitle subtitle : updatedSubtitles) {	        		
	        		doNotification(anime, subtitle);
				}
	        	
	        	TextView newCountText = (TextView) animeView.findViewById(R.id.newCountText);
	        	if (updatedSubtitles.size() == 1) 
	        		newCountText.setText("" + updatedSubtitles.size() + " новая");
	        	else
	        		newCountText.setText("" + updatedSubtitles.size() + " новых");	  
	        	newCountText.setVisibility(updatedSubtitles.size() == 0 ? View.INVISIBLE : View.VISIBLE);
	        	newCountText.setTypeface(segoe);
	        	newCountText.setTag(anime.baseId);
	        	
	        	ImageButton btnRemove = (ImageButton) animeView.findViewById(R.id.btnRemove);
	        	btnRemove.setOnClickListener(new OnClickListener() {
					
					public void onClick(View v) {
						removeAnime(anime);						
					}
				});	        	
	        	
	        	ImageButton btnDetails = (ImageButton) animeView.findViewById(R.id.btnDetails);
	        	btnDetails.setOnClickListener(new OnClickListener() {
					
					public void onClick(View v) {
						Intent intent = new Intent(_context, SubtitlesListActivity.class);
						Bundle bundle = new Bundle();
						bundle.putInt("baseId", anime.baseId);
						intent.putExtras(bundle);
						_context.startActivity(intent);
					}
				});	    
	        	
	        	animeTable.addView(animeView);
			} catch (Exception e) {
				e.printStackTrace();
			}
		} 		
	}
	
	public void refreshNewLabels(TableLayout animeTable) {
		for (int i = 0; i < animeTable.getChildCount(); i++) {
			View animeView = animeTable.getChildAt(i);			
			
			TextView newCountText = (TextView) animeView.findViewById(R.id.newCountText);
			int baseId = (Integer)newCountText.getTag();
			Anime anime;
			try {
				anime = _helper.getAnime(baseId);
				List<Subtitle> updatedSubtitles = _helper.subtitlesUpdated(anime);
				newCountText.setVisibility(updatedSubtitles.size() == 0 ? View.INVISIBLE : View.VISIBLE);
			} catch (SQLException e) {
				Log.i(LOG_TAG, "Unable to update labels");
				e.printStackTrace();
			}			        	        	        
		}
	}
}
