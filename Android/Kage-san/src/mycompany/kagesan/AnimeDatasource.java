package mycompany.kagesan;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.EventListener;
import java.util.Hashtable;
import java.util.Timer;
import java.util.TimerTask;

import mycompany.kagesan.R;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Subtitle;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;

public class AnimeDatasource extends Service {
	private static final long UPDATE_INTERVAL = 60000;
	private final String LOG_TAG = getClass().getSimpleName();
	private final IBinder adBinder = new AnimeDatasourceBinder();	
	
	private Timer timer = new Timer();
	private Hashtable<Integer, Boolean> _loadedFlags;
	private ArrayList<Anime> _items;
	private boolean _loading;
	private Handler _handler;
	private DatabaseHelper _helper; 
	
	private OnDataChangedEventListener _onDataChangedEventListener;
	//public final AnimeDatasourceDelegate _delegate;	
		
	public interface OnDataChangedEventListener extends EventListener {
		public void onDataChangedEventOccurred();
	}
	
	public void setOnDataChangedEventListener(OnDataChangedEventListener onDataChangedEventListener) {
		_onDataChangedEventListener = onDataChangedEventListener;
	}
	
	public DatabaseHelper getHelper() {
		return _helper;
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
											
											_onDataChangedEventListener.onDataChangedEventOccurred();											
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
				_onDataChangedEventListener.onDataChangedEventOccurred();				
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
						_onDataChangedEventListener.onDataChangedEventOccurred();						
					}
				} catch (SQLException e) {
					Log.i(LOG_TAG, "unabled to add anime " + objId);
					e.printStackTrace();
				}				
			}
		}).run();
	}
	
	public void doNotification(Anime anime, Subtitle subtitle) {

		final int NOTIF_ID = subtitle.srtId;  
			
		NotificationManager notifManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);  
		Notification note = new Notification(R.drawable.icon, "Новая серия", System.currentTimeMillis());  
		note.flags = Notification.FLAG_AUTO_CANCEL;
		
		PendingIntent intent = PendingIntent.getActivity(this, 0, new Intent(this, AnimeDatasource.class), 0);  		  
		   		  		   		 			
		CharSequence contentText = subtitle.seriesCount + " серия от " + subtitle.fansubgroup.name;
		 
		note.setLatestEventInfo(this, anime.name, contentText, intent);
		notifManager.notify(NOTIF_ID, note);
	}
		
	@Override
	public void onCreate() {
		super.onCreate();				
		_items = new ArrayList<Anime>();
		_loadedFlags = new Hashtable<Integer, Boolean>();
		_helper = new DatabaseHelper(this);		
		_handler = new Handler();
		//this.loadItems();		
		
		pollForUpdates();
	}
	
	private void pollForUpdates() {
		timer.scheduleAtFixedRate(new TimerTask() {
			@Override
			public void run() {
				loadItems();
			}
		}, 0, UPDATE_INTERVAL);
		Log.i(LOG_TAG, "Timer started.");
	}

	
	@Override
	public void onDestroy() {
		super.onDestroy();
		if (timer != null) {
			timer.cancel();
		}
		Log.i(getClass().getSimpleName(), "Timer stopped.");
		
		super.onDestroy();
	}
	
	public class AnimeDatasourceBinder extends Binder {
		AnimeDatasource getService() {
			return AnimeDatasource.this;
		}
	}
	
	@Override
	public IBinder onBind(Intent arg0) {		
		return adBinder;
	}
}
