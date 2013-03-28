package it.ebruni.caroid;

import it.ebruni.caroid.R.id;

import java.util.ListIterator;
import android.os.Bundle;
import android.os.Handler;
import android.app.Activity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

public class Mp3player extends Activity implements MultimediaPlayerListener, SeekBar.OnSeekBarChangeListener {
	
	// Internal Objects
	private MultimediaPlayer mp = new MultimediaPlayer();
	private SongsManager songManager = new SongsManager();
	private Handler tmrUpdateProgressBar = new Handler();
	private ListIterator<FileSong> songsIterator;
	
	// GUI Objects
	private SeekBar pbSong;
	private Button btnPlayPause;
	private TextView txtHeader;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_mp3player);
		
		// Get GUI Objects
		pbSong = (SeekBar) findViewById(R.id.pbSong);
		btnPlayPause = (Button) findViewById(R.id.btnPlayPause);
		txtHeader=(TextView) findViewById(id.txtHeader);
		
		// config Objects
		//mp.setOnCompletionListener(this);
		mp.setMultimediaPlayerListener(this);
		pbSong.setOnSeekBarChangeListener(this);
		
		songManager.refreshPlayList(this);
		songsIterator = songManager.listIterator(0);
		if (songManager.size()>0)  mp.playSong(songsIterator.next());

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.mp3player, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		//case android.R.id.home:
			// This ID represents the Home or Up button. In the case of this
			// activity, the Up button is shown. Use NavUtils to allow users
			// to navigate up one level in the application structure. For
			// more details, see the Navigation pattern on Android Design:
			//
			// http://developer.android.com/design/patterns/navigation.html#up-vs-back
			//
		//	NavUtils.navigateUpFromSameTask(this);
		//	return true;
		}
		return super.onOptionsItemSelected(item);
	}
	
	public void btnPlayPause_onClick(View item) {
		if(mp.isPlaying()){
			mp.pause();
		} else {
			mp.start();
		}
	}

	public void btnNext_onClick(View item) {
		playNext();
	}

	private void playNext() {
		if (!songsIterator.hasNext()) songsIterator = songManager.listIterator(0);
		mp.playSong(songsIterator.next());
	}

	
	private Runnable thrUpdateProgressBar = new Runnable() {		
		@Override
		public void run() {
			long currentPos = mp.getCurrentPosition();
			pbSong.setProgress((int) currentPos/1000);
			tmrUpdateProgressBar.postDelayed(this, 500);
			
		}
	};
	
	@Override
	public void onProgressChanged(SeekBar arg0, int arg1, boolean arg2) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onStartTrackingTouch(SeekBar arg0) {
		// TODO Auto-generated method stub
		tmrUpdateProgressBar.removeCallbacks(thrUpdateProgressBar);
	}

	@Override
	public void onStopTrackingTouch(SeekBar arg0) {
		// TODO Auto-generated method stub
		mp.pause();
		mp.seekTo(arg0.getProgress()*1000);
		mp.start();
	}

	@Override
	public void onMediaStart(MultimediaPlayer mp) {
		// TODO Auto-generated method stub
		btnPlayPause.setText("=");
		FileSong cS = mp.getCurrentSong();
		txtHeader.setText(cS.getArtist() + " - " +  cS.getTitle());
		tmrUpdateProgressBar.removeCallbacks(thrUpdateProgressBar);
		pbSong.setMax((int) mp.getDuration()/1000);
		tmrUpdateProgressBar.postDelayed(thrUpdateProgressBar, 500);
	}

	@Override
	public void onMediaPause(MultimediaPlayer mp) {
		// TODO Auto-generated method stub
		btnPlayPause.setText(">");		
		tmrUpdateProgressBar.removeCallbacks(thrUpdateProgressBar);
	}

	@Override
	public void onMediaComplete(MultimediaPlayer mp) {
		// TODO Auto-generated method stub
		playNext();
		
	}
}
