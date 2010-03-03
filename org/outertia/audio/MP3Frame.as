////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio {
	import org.outertia.audio.MP3Header;
	import flash.utils.ByteArray;
	public class MP3Frame {
		public static const SAMPLES:int = 1152;
		public static const SAMPLES_L1:int = 384;
		private var _header:MP3Header;
		public var data:ByteArray;
		public var length:int;
		public var location:int;
		public var dataOffset:int;
		public var timestamp:Number;
		public var byteLocation:uint;
		public function MP3Frame(hdr:MP3Header=null,datat:ByteArray=null){
			if(!hdr) hdr = new MP3Header();
			if(!datat) datat = new ByteArray();
			this.data = datat;
			this._header = hdr;
		}
		public function set header(hdr:MP3Header):void { if(!_header) _header = hdr; }
		
		public function get rate():int { return _header.rate; }
		public function get channels():int { return _header.channels; }
		public function get freq():int { return _header.freq; }
		//public function get 
		
	}
}