package it.ebruni.caroid;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.MediaStore.Audio;



public class SongsManager extends ArrayList<FileSong> {
	
	// Constructor
	public SongsManager(){
		
	}
	
	/**
	 * Function to read all mp3 files from sdcard
	 * and store the details in ArrayList
	 * */
/*	public void refreshPlayList(){
		File home = new File(MEDIA_PATH);
		
		File[] fList = home.listFiles(new FileExtensionFilter());

		if (null != fList && fList.length > 0) {
			for (File file : home.listFiles(new FileExtensionFilter())) {
				FileSong song = new FileSong();
				song.setTitle(file.getName().substring(0, (file.getName().length() - 4)));
				song.setPath(file.getPath());
				
				// Adding each song to SongList
				this.add(song);
			}
		}
	}*/
	
	public void refreshPlayList(Activity activity){
		String selection = MediaStore.Audio.Media.IS_MUSIC + " != 0";

		String[] projection = {
		        Audio.Media._ID,
		        Audio.Media.ARTIST,
		        Audio.Media.TITLE,
		        Audio.Media.DATA,
		        Audio.Media.DISPLAY_NAME,
		        Audio.Media.DURATION
		};
		Cursor cursor = activity.managedQuery(
		        Audio.Media.EXTERNAL_CONTENT_URI,
		        projection,
		        selection,
		        null,
		        null);



		while(cursor.moveToNext()) {
		        FileSong song = new FileSong();
				song.setTitle(cursor.getString(cursor.getColumnIndex(Audio.Media.TITLE)));
				song.setFilename(cursor.getString(cursor.getColumnIndex(Audio.Media.DISPLAY_NAME)));
				song.setArtist(cursor.getString(cursor.getColumnIndex(Audio.Media.ARTIST)));
				int audioId =cursor.getInt( cursor.getColumnIndex(Audio.Media._ID) ); 
				Uri uri = Uri.withAppendedPath( Audio.Media.EXTERNAL_CONTENT_URI,
                        Integer.toString(audioId) );
				song.setPath(uri.toString() );
				
				// Adding each song to SongList
				this.add(song);
		}
	}
	
	/**
	 * Class to filter files which are having .mp3 extension
	 * */
	/*class FileExtensionFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
			return (name.endsWith(".mp3") || name.endsWith(".MP3"));
		}
	}*/


}
