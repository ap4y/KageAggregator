package mycompany.kagesan;

import mycompany.kagesan.common.AnimeDatasource;
import mycompany.kagesan.common.AnimeDatasourceDelegate;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
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
     
    @Override
    protected void onRestart() {
    	TableLayout animeTable = (TableLayout) findViewById(R.id.animeTable);    	
    	_dataSource.refreshNewLabels(animeTable);    	
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
    	_dataSource.infiltrateAnimeView(animeTable);
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
    
	public void animeDatasourceDidChanged() {
		Log.i(LOG_TAG, "anime items count " + _dataSource.getItems().size());
		this.reloadAnime();
	}
}