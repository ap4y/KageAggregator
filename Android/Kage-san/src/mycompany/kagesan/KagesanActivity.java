package mycompany.kagesan;

import mycompany.kagesan.common.AnimeDatasource;
import mycompany.kagesan.common.AnimeDatasourceDelegate;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class KagesanActivity extends Activity implements AnimeDatasourceDelegate {
	private final String LOG_TAG = getClass().getSimpleName();
	
	private AnimeDatasource _dataSource;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        _dataSource = new AnimeDatasource(this);
        setContentView(R.layout.main);        
    }

	public void animeDatasourceDidChanged() {
		Log.i(LOG_TAG, "anime items count " + _dataSource.getItems().size());
	}
}