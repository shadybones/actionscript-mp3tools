package {
    import flash.net.URLLoader;
    import flash.utils.ByteArray;
    public class MP3{
        public static function parse(obj):MP3{
			var data:ByteArray;
			if(obj is Event && ev.target.data is ByteArray) data = ev.target.data;
			else if(obj is ByteArray) data = obj;
			else return;
			if(data.length < 512) return;
			
			var frames:Vector = new Vector.<MP3Frame>();
			var mp3 = new MP3(frames);
            var version:int = 1;
            var currByte:uint;
			data.position = 0;
			while(data.readByte()==0){}
			data.position--;
			if(data.readUTFBytes(3) == "ID3") mp3.ID3 = ID3v2.parse(data);
			while(data.readByte()==0){}
			data.position--;
			while (data.bytesAvailable){
				if (data.readUnsignedByte() != 0xFF ) continue;
				currByte = data.readUnsignedByte();
				//only accepts version 1 layer 3 otherwise use below:
				//    if(currByte>>5 != 7) continue;
				//    version = currByte>>3 & 3; //0==version 2.5, 3==version 1, 2==version 2, 1==reserved
				//    hdr.rate = MP3Header.L3Vrate[version][(rateByte>>4)&15];
				//    hdr.freq = MP3Header.FREQ[ (currByte>>2)&3 ] / (4-version);
				if(currByte>>4 != 0xF) continue;
				if(currByte & 0xFE != 0xFA) break;
				
				var hdr = new MP3Header();
				var frm = new MP3Frame(hdr);
				hdr.crc = (~currByte & 1); //16 bit crc follows header
				hdr.version = version;
                
				currByte = data.readUnsignedByte();
				hdr.rate = MP3Header.L3V1[ (currByte>>4)&15 ];  
				hdr.freq = MP3Header.FREQ[ (currByte>>2)&3 ];
                hdr.padded = (currByte>>1 & 1); //8 bit padding on the end
				
				currByte = data.readUnsignedByte();
				hdr.channel = currByte>>6 & 3;
				hdr.channelMode = currByte>>3 & 3;
				
				//next two bytes might be crc
				if(hdr.crc) data.position += 2;
				//VBR may have bit reseviours (borrow from surrounding frames), so can't cut the MP3
				
				frm.length = 144 * hdr.rate / hdr.freq + hdr.padded;
				frm.location = frames.length;
				frm.data.writeBytes(data, data.position , frameLength);
				
				frm.data.position = 0;
				var st:String = frm.data.readUTFBytes(2);
				frm.data.position = frm.data.length - 3;
				trace(st," ",frm.data.readUTFBytes(3));
				
				frames.push(frm);
				data.position += frm.length - 1; //1 is fudge factor, should not be needed
            }
			data.position = data.position.length - 128;
			if(data.readUTFBytes(3) == 'TAG'){
				mp3.info = new ID3v1(data.readUTFBytes(30),data.readUTFBytes(30),data.readUTFBytes(30),data.readUTFBytes(4),data.readUTFBytes(30),data.readUnsignedByte());
			}
			return mp3;
        }
		
		public var frames:Vector.<MP3Frame>;
		public var info:ID3v1;
		public var ID3:ID3v2;
		public function MP3(frms:Vector.<MP3Frame>=null):void{
			if(!frms) frames = new Vector.<MP3Frame>();
			else frames = frms;
		}
		public function export():ByteArray{
			//prepares output for use with Load.loadbytes;
		}
    }
}
