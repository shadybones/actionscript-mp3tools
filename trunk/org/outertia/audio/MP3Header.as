package mine.audio {
	public class MP3Header{
		public static const L3V1:Array = [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0];
		public static const L3V2:Array = [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0];
		public static const FREQ:Array = [44100,48000,32000,0];
		public static const L3Vrate:Array = [ [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0] , 
											  [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0] ,
											  [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0],
											  [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0] ];
		
		public var rate:int;
		public var freq:int;
		public var crc:uint;
		public var channels:int;
		public var version:int;
		public var padded:int;
		public function MP3Header( rate:int = 11, channels:int = 2, version:int = 1, freq:int = 0, crc:uint = 0, padded:int = 0){
			this.version = version;
			this.freq = freq;
			this.rate = rate;
			this.channels = channels;
			this.crc = crc;
			this.padded = padded;
		}
	}
}