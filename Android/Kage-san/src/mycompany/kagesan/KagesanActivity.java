package mycompany.kagesan;

import mycompany.kagesan.common.AnimeDatasource;
import mycompany.kagesan.common.AnimeDatasourceDelegate;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TableLayout;

public class KagesanActivity extends Activity implements AnimeDatasourceDelegate {
	private final String LOG_TAG = getClass().getSimpleName();
	
	private AnimeDatasource _dataSource;
			
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setContentView(R.layout.main);  
        _dataSource = new AnimeDatasource(this, this);        
        this.showAddNew();
    }

    private void reloadAnime() {
    	TableLayout animeTable = (TableLayout) findViewById(R.id.animeTable);    	       
        animeTable.removeAllViews();
    	_dataSource.infiltrateAnimeView(animeTable);
    }
    
    private void showAddNew() {
		final EditText newAnimeText = (EditText)findViewById(R.id.baseIdText);        	
    	Button addButton = (Button)findViewById(R.id.btnAdd);        	
    	
    	addButton.setOnTouchListener(new OnTouchListener() {
			
			public boolean onTouch(View v, MotionEvent event) {
				_dataSource.addAnime(Integer.parseInt(newAnimeText.getText().toString()));
				
				return true;
			}
		});        	
    }
    
	public void animeDatasourceDidChanged() {
		Log.i(LOG_TAG, "anime items count " + _dataSource.getItems().size());
		this.reloadAnime();
	}
}