package it.ebruni.caroid;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.view.Menu;
import android.view.View;


public class MainActivity extends Activity  {

	private String logtag ="main_activity";
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}
	
	public void btOpenMp3Player_OnClick(View btOpenMp3Player)  {
          Log.d(logtag ,"onClick() called - start button");   
          Intent intent = new Intent(this, Mp3player.class);
          startActivity(intent);
          Log.d(logtag,"onClick() ended - start button");
    };

}
