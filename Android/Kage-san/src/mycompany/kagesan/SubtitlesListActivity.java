package mycompany.kagesan;

import java.sql.SQLException;

import com.j256.ormlite.android.apptools.OrmLiteBaseActivity;

import mycompany.kagesan.model.Anime;
import mycompany.kagesan.model.DatabaseHelper;
import mycompany.kagesan.model.Subtitle;
import android.app.NotificationManager;
import android.graphics.Typeface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

public class SubtitlesListActivity extends OrmLiteBaseActivity<DatabaseHelper> {
	private final String LOG_TAG = getClass().getSimpleName();
	
	private Anime _anime;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.subtitlelist);
		
		Bundle bundle = getIntent().getExtras();
		int baseId = bundle.getInt("baseId");
		
		try {
			_anime = getHelper().getAnime(baseId);			
			fillData();
		} catch (SQLException e) {
			Log.i(LOG_TAG, "Unable to get anime");
			e.printStackTrace();
		} 
	}
	
	@Override
	public void onBackPressed() {
		//getHelper().setIsWatched(_anime);
		NotificationManager notifManager = (NotificationManager) this.getSystemService(NOTIFICATION_SERVICE);
		
		for (Subtitle subtitle : _anime.subtitles) {
			subtitle.updated = false;
			notifManager.cancel(subtitle.srtId);
			try {
				getHelper().getSubtitleDao().update(subtitle);
			} catch (SQLException e) {
				Log.i("DatabaseHelper", "Unable to set isWatched");
				e.printStackTrace();
			}
		}			
		
		super.onBackPressed();
	}
	
	private void fillData() throws SQLException {
		TableLayout tblSubtitles = (TableLayout) findViewById(R.id.tblSubtitles);
		tblSubtitles.removeAllViews();
		
		Typeface segoe = Typeface.createFromAsset(getAssets(), "fonts/segoeui.TTF");
		Typeface segoeBold = Typeface.createFromAsset(getAssets(), "fonts/seguibd.ttf");
		
		for (Subtitle subtitle : getHelper().subtitlesBySeriesCount(_anime)) {
        	View subtitleView = View.inflate(this, R.layout.subtitleview, null);

        	TextView seriesCount = (TextView) subtitleView.findViewById(R.id.lbSeriesCount);
			seriesCount.setText(subtitle.seriesCount + "");
			seriesCount.setTypeface(segoe);
			
			TextView authors = (TextView) subtitleView.findViewById(R.id.lbGroupNames);			
			authors.setText(subtitle.fansubgroup.name.trim());
			authors.setTypeface(segoeBold);
			
			if (subtitle.updated) {
				TableRow row = (TableRow) subtitleView.findViewById(R.id.subtitleRow);
				row.setBackgroundColor(0xff91b900);
			}
			
			tblSubtitles.addView(subtitleView);
		}
	}
}
