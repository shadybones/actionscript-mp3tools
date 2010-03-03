////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio {
    import flash.net.URLLoader;
    import flash.utils.ByteArray;
	import flash.events.Event;
	import org.outertia.audio.*;
	import org.outertia.audio.ID3.ID3v2;
	import org.outertia.audio.ID3.ID3v1;
    public class MP3{
        public static function parse(obj):MP3{
			var data:ByteArray;
			if(obj is Event && obj.target.data is ByteArray) data = obj.target.data;
			else if(obj is ByteArray) data = obj;
			else return null;
			if(data.length < 512) return null;
			
			var frames:Vector.<MP3Frame> = new Vector.<MP3Frame>();
			var mp3 = new MP3(frames);
            var version:int = 1;
			var start:uint;
			var Ostart:int = -1;
            var currByte:uint;
			data.position = 0;
			while(data.readByte()==0){}
			--data.position;
			if(data.readUTFBytes(3) == "ID3"){
				data.position = data.position - 3;  
				Ostart = data.position; 
				mp3.ID3 = ID3v2.parse(data);
			}else data.position = data.position - 3;
			while(data.readByte()==0){}
			--data.position;
			trace(data.position);
			while (data.bytesAvailable){
				if (data.readUnsignedByte() != 0xFF ) continue;
				start = data.position - 1;
				if(data.bytesAvailable > 2) currByte = data.readUnsignedByte();
				else break;
				//only accepts version 1 layer 3 otherwise use below:
				    if(currByte>>5 != 7) continue;
				    version = currByte>>3 & 3; //0==version 2.5, 3==version 1, 2==version 2, 1==reserved
					var hdr = new MP3Header();
					hdr.crc = (~currByte & 1); //16 bit crc follows header
					hdr.layer = currByte>>1 & 3;//3 == layer I, 2 == layer II, 1==layer III, 0==reserved
					currByte = data.readUnsignedByte();
				    if(hdr.layer == 1 || (hdr.layer == 2 && version != 3) ) hdr.rate = MP3Header.L3Vrate[version][(currByte>>4)&15];
					else if(hdr.layer == 2) hdr.rate = MP3Header.L2V1[(currByte>>4)&15];
					else if (hdr.layer == 3) hdr.rate = MP3Header.L1V[version&1][(currByte>>4)&15];
				    hdr.freq = MP3Header.FREQ[ (currByte>>2)&3 ] / (4-version);
				//USE if only version 1 layer 3 wanted
					//if(currByte>>4 != 0xF) continue;
					//if(currByte & 0xFE != 0xFA) break;
					//var hdr = new MP3Header();
					//hdr.crc = (~currByte & 1); //16 bit crc follows header
					//currByte = data.readUnsignedByte();
					//hdr.rate = MP3Header.L3V1[ (currByte>>4)&15 ];  
					//hdr.freq = MP3Header.FREQ[ (currByte>>2)&3 ];
				
				var frm = new MP3Frame(hdr);
				hdr.version = version;
                hdr.padded = (currByte>>1 & 1); //8 bit padding on the end
				//trace("found frame at",start,hdr.rate,hdr.freq);
				
				currByte = data.readUnsignedByte();
				hdr.channels = currByte>>6 & 3;
				hdr.channelMode = currByte>>3 & 3;
				
				//next two bytes might be crc
				if(hdr.crc) data.position += 2;
				//VBR may have bit reseviours (borrow from surrounding frames), so can't cut the MP3
				frm.timestamp = mp3.totalTime;
				if(hdr.layer == 3){
					frm.length = ((12000 * hdr.rate) / hdr.freq + hdr.padded) * 4;
					mp3.totalSamples += 384;
					mp3.totalTime += 384/ hdr.freq;
				} else {
					frm.length = (144000 * hdr.rate) / hdr.freq + hdr.padded;
					mp3.totalSamples += 1152;
					mp3.totalTime += 1152 / hdr.freq;
				}
				frm.location = frames.length;
				frm.byteLocation = start;
				//frm.data.writeBytes(data, data.position , frameLength);
				data.readBytes(frm.data,0,Math.min(frm.length-4, data.bytesAvailable));
				frm.data.position = 0;
				
				frames.push(frm);
				//data.position = data.position - 1; //-- is fudge factor, should not be needed
            }
			data.position = data.position - Math.min(128,data.position);
			if(data.bytesAvailable > 127 && data.readUTFBytes(3) == 'TAG'){
				mp3.info = new ID3v1(data.readUTFBytes(30),data.readUTFBytes(30),data.readUTFBytes(30),data.readUTFBytes(4),data.readUTFBytes(30),data.readUnsignedByte());
			}
			//if(Ostart<0) 
				Ostart = frames[0].byteLocation;
			mp3.parsedLength = data.length - Ostart;
			return mp3;
        }
		
		public var frames:Vector.<MP3Frame>;
		public var info:ID3v1;
		public var ID3:ID3v2;
		public var totalSamples:uint;
		public var totalTime:Number;
		public var parsedLength:uint;
		public function MP3(frms:Vector.<MP3Frame>=null):void{
			if(!frms) frames = new Vector.<MP3Frame>();
			else frames = frms;
			totalSamples = 0;
			totalTime = 0;
		}
		public function export():ByteArray{
			//prepares output for use with Load.loadbytes;
			return null;
		}
    }
}
