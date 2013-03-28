package it.ebruni.caroid;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import android.media.MediaPlayer;

public class MultimediaPlayer extends MediaPlayer implements MediaPlayer.OnCompletionListener {
	
	private FileSong currentSong;
	
	private List<MultimediaPlayerListener> _listeners = new ArrayList<MultimediaPlayerListener>();
	public synchronized void setMultimediaPlayerListener(MultimediaPlayerListener listener)  {
		_listeners.add(listener);
	}
	public synchronized void removeMultimediaPlayerListener(MultimediaPlayerListener listener)   {
		_listeners.remove(listener);
	}

	public MultimediaPlayer() {
		super();
		this.setOnCompletionListener(this);
	}
	
	public void playSong(FileSong song) {
		// Play song
		try {
        	this.reset();
        	currentSong=song;
        	this.setDataSource(currentSong.getPath());
        	this.prepare();
        	this.start();		
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
	
	
	/**
	 * @return the currentSong
	 */
	public FileSong getCurrentSong() {
		return currentSong;
	}
	/* (non-Javadoc)
	 * @see android.media.MediaPlayer#pause()
	 */
	@Override
	public void pause() throws IllegalStateException {
		// TODO Auto-generated method stub
		super.pause();
		onPauseFire();
	}
	/* (non-Javadoc)
	 * @see android.media.MediaPlayer#start()
	 */
	@Override
	public void start() throws IllegalStateException {
		// TODO Auto-generated method stub
		super.start();
		onStartFire();
	}
	
	/* (non-Javadoc)
	 * @see android.media.MediaPlayer#stop()
	 */
	@Override
	public void stop() throws IllegalStateException {
		// TODO Auto-generated method stub
		super.stop();
	}
	private synchronized void onStartFire() {
	  Iterator<MultimediaPlayerListener> i = _listeners.iterator();
	  while(i.hasNext())  {
		  i.next().onMediaStart(this);
	  }
	}
	
	private synchronized void onPauseFire() {
	  Iterator<MultimediaPlayerListener> i = _listeners.iterator();
	  while(i.hasNext())  {
		  i.next().onMediaPause(this);
	  }
	}
	
	private synchronized void onCompleteFire() {
		  Iterator<MultimediaPlayerListener> i = _listeners.iterator();
		  while(i.hasNext())  {
			  i.next().onMediaComplete(this);
		  }
		}
	
	
	@Override
	public void onCompletion(MediaPlayer mp) {
		// TODO Auto-generated method stub
		onCompleteFire();
	}

}



