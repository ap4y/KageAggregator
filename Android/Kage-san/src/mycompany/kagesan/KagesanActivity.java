package mycompany.kagesan;

import java.sql.SQLException;
import java.util.List;

import mycompany.kagesan.SubtitlesListActivity;
import mycompany.kagesan.AnimeDatasource.OnDataChangedEventListener;
import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.Subtitle;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.BitmapFactory;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TableLayout;
import android.widget.TextView;

public class KagesanActivity extends Activity {
	private final String LOG_TAG = getClass().getSimpleName();
	
	private AnimeDatasource _dataSource;
			
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setContentView(R.layout.main);
        doBindService();                  
        this.showAddNew();
    }
    
    private ServiceConnection mConnection = new ServiceConnection() {
		public void onServiceConnected(ComponentName className, IBinder binder) {
			_dataSource = ((AnimeDatasource.AnimeDatasourceBinder) binder).getService();
			_dataSource.setOnDataChangedEventListener(new OnDataChangedEventListener() {
				
				public void onDataChangedEventOccurred() {
					Log.i(LOG_TAG, "anime items count " + _dataSource.getItems().size());
					reloadAnime();
				}
			});
		}

		public void onServiceDisconnected(ComponentName className) {
			_dataSource = null;
		}
	};
	
    void doBindService() {
    	Intent intent = new Intent(this, AnimeDatasource.class);
		bindService(intent, mConnection, BIND_AUTO_CREATE);
	}
     
    @Override
    protected void onRestart() {
    	TableLayout animeTable = (TableLayout) findViewById(R.id.animeTable);    	
    	refreshNewLabels(animeTable);    	
    	Log.i(LOG_TAG, "restarted");
    	
    	super.onRestart();
    }
   
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
    	MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.mainmenu, menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	switch (item.getItemId()) {
		case R.id.refresh:
			_dataSource.loadItems();
			return true;
		default:
			return super.onOptionsItemSelected(item);			
		}
    }
    
    private void reloadAnime() {
    	TableLayout animeTable = (TableLayout) findViewById(R.id.animeTable);    	       
        animeTable.removeAllViews();
    	infiltrateAnimeView(animeTable);
    }
    
    private void showAddNew() {
		final EditText newAnimeText = (EditText)findViewById(R.id.baseIdText);        	
    	Button addButton = (Button)findViewById(R.id.btnAdd);        	
    	
    	addButton.setOnClickListener(new OnClickListener() {
			
			public void onClick(View v) {
				InputMethodManager imm = (InputMethodManager)getSystemService(INPUT_METHOD_SERVICE);
				imm.hideSoftInputFromWindow(newAnimeText.getWindowToken(), 0);
				_dataSource.addAnime(Integer.parseInt(newAnimeText.getText().toString()));				
			}
		});    	       
    }
    
	public void infiltrateAnimeView(TableLayout animeTable) {
		Typeface segoe = Typeface.createFromAsset(this.getAssets(), "fonts/segoeui.TTF");
		Typeface segoeBold = Typeface.createFromAsset(this.getAssets(), "fonts/seguibd.ttf");
		
		for (final Anime anime : _dataSource.getItems()) {    
			try {
				View animeView = View.inflate(this, R.layout.animeview, null);	        	
	        	        	
	        	TextView animeName = (TextView) animeView.findViewById(R.id.animeNameText);
	        	animeName.setText(anime.name);
	        	animeName.setTypeface(segoeBold);
	        	
	        	ImageView animeImage = (ImageView) animeView.findViewById(R.id.animeImageView);
	        	animeImage.setImageBitmap(BitmapFactory.decodeByteArray(anime.imageData, 0, anime.imageData.length));	
	        	
	        	TextView subCountText = (TextView) animeView.findViewById(R.id.subCountText);
	        	Subtitle maxSub = _dataSource.getHelper().subtitlesWithMaxCount(anime);	        	
	        	int maxSeries = maxSub == null ? 0 : maxSub.seriesCount;
	        	subCountText.setText("переведено " + maxSeries);
	        	subCountText.setTypeface(segoe);
	        	
	        	List<Subtitle> updatedSubtitles = _dataSource.getHelper().subtitlesUpdated(anime);
	        	for (Subtitle subtitle : updatedSubtitles) {	        		
	        		_dataSource.doNotification(anime, subtitle);
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
						_dataSource.removeAnime(anime);						
					}
				});	        	
	        	
	        	ImageButton btnDetails = (ImageButton) animeView.findViewById(R.id.btnDetails);
	        	btnDetails.setOnClickListener(new OnClickListener() {
					
					public void onClick(View v) {
						Intent intent = new Intent(KagesanActivity.this, SubtitlesListActivity.class);
						Bundle bundle = new Bundle();
						bundle.putInt("baseId", anime.baseId);
						intent.putExtras(bundle);
						startActivity(intent);
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
				anime = _dataSource.getHelper().getAnime(baseId);
				List<Subtitle> updatedSubtitles = _dataSource.getHelper().subtitlesUpdated(anime);
				newCountText.setVisibility(updatedSubtitles.size() == 0 ? View.INVISIBLE : View.VISIBLE);
			} catch (SQLException e) {
				Log.i(LOG_TAG, "Unable to update labels");
				e.printStackTrace();
			}			        	        	        
		}
	}
}