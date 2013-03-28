package it.ebruni.caroid;

public interface MultimediaPlayerListener  {
	public void onMediaStart(MultimediaPlayer mp);
	public void onMediaPause(MultimediaPlayer mp);
	public void onMediaComplete(MultimediaPlayer mp);
}