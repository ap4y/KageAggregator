package mycompany.kagesan;

import com.j256.ormlite.android.apptools.OrmLiteBaseActivity;

import mycompany.kagesan.model.DatabaseHelper;
import android.os.Bundle;

public class KagesanActivity extends OrmLiteBaseActivity<DatabaseHelper> {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);        
    }
}