////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio {
	public class MP3Header{
		public static const L3V1:Array = [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0];
		public static const L2V1:Array = [0,32,48,56,64,80,96,112,128,160,192,224,256,320,384,0];
		public static const L3V2:Array = [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0];
		public static const FREQ:Array = [44100,48000,32000,44100];//44100 is at i==3 in case somethings wrong with mp3
		public static const L3Vrate:Array = [ [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0] , 
											  [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0] ,
											  [0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0],
											  [0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0] ];
		public static const L1V:Array = [ [0,32,48,56,64,80,96,112,128,144,160,176,192,224,256,0], 
										  [0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,0] ];
		
		public var rate:uint;
		public var freq:uint;
		public var crc:uint;
		public var channels:uint;
		public var version:uint;
		public var padded:uint;
		public var layer:uint;
		public var channelMode:uint;
		public function MP3Header( rate:uint = 192, channels:uint = 2, version:uint = 1, freq:uint = 0, crc:uint = 0, padded:uint = 0, layer:uint = 1){
			if( version < L3Vrate.length ) this.version = version;
			if( freq < FREQ.length ) this.freq = freq;
			if( L3Vrate[version].indexOf(rate) >= 0 ) this.rate = rate;
			if(channels < 4) this.channels = channels;
			this.crc = crc;
			this.padded = padded;
			this.layer = layer;
		}
	}
}