package mine.audio {
	import MP3Header;
	import flash.utils.ByteArray;
	public class MP3Frame {
		public static const samples:int = 1152;
		private var _header:MP3Header;
		public var data:ByteArray;
		public var length:int;
		public var location:int;
		public var dataOffset:int;
		public function MP3Frame(hdr:MP3Header=null,data:ByteArray=null){
			if(!hdr) _header = new MP3Header();
			if(!data) data = new ByteArray();
		}
		public function set header(hdr:MP3Header):void{ if(!_header) _header = hdr; }
		
		public function get rate:int { return _header.rate; }
		public function get channels:int { return _header.channels; }
		public function get freq:int { return _header.freq; }
		//public function get 
		
	}
}