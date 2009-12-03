package mine.audio.ID3 {
	import flash.utils.ByteArray;
	import mine.core.CRC32;
	import mine.audio.ID3.ID3v2Frame;
	
	public class ID3v2 {
		public static const TITLE:String = "TIT2";
		public static const ARTIST:String = "TPE1";
		public static const ALBUM:String = "TALB";
		public static const YEAR:String = "TYER";
		public static const TRACK:String = "TRCK";
		public static const COMMENT:String = "COMM";
		public static const GENRE:String = "TCON";
		public static const PICTURE:String = "APIC";
		public static const ENCRYPTION:String = "ENCR";
		public static const LINK:String = "LINK";
		public static const LOOKUP_TABLE:String = "MLLT";
		public static const PLAY_COUNT:String = "PCNT";
		public static const SYNC_LYRICS:String = "SYLT";
		public static const EQUALIZATION:String = "EQUA";
		public static const COMPOSER:String = "TCOM";
		public static const LANGUAGE:String = "TLAN";
		public static const LENGTH:String = "TLEN";
		public static const ARTIST2:String = "TPE2";
		public static const UNSYNC_LYRICS:String = "USLT";
		public static const ARTIST_WEBPAGE:String = "WOAR";
		public static const COPYRIGHT:String = "WCOP";
		public static const PRIVATE:String = "PRIV";
		public static const UNIQUE_ID:String = "UFID";
		public static const CD_IDENTIFIER:String = "MCDI";
		public static const SYNC_TEMPO:String = "SYTC";
		public static const POSITION_SYNC:String = "POSS";
		public static const GROUP_ID:String = "GRID";
		public static const POPULARIMETER:String = "POPM";
		public static const USER_URL:String = "WXXX";
		public static const INVOLVED_PEOPLE:String = "IPLS";
		public static const TERMS_OF_USE:String = "USER";
		//LOTS more
		
		//privides an easy way to reference less common, but available, TAGS to their classes
		public static const FRAME_CLASSES:Object = { APIC:ID3ImageFrame,
							PRIV:ID3MultiFrame, UFID:ID3MultiFrame, MCDI:ID3MultiFrame, SYTC:ID3MultiFrame,
							EQUA:ID3MultiFrame, GRID:ID3MultiFrame, ENCR:ID3MultiFrame, POSS:ID3MultiFrame,
							POPM:ID3MultiFrame, PCNT:ID3MultiFrame,
							WXXX:ID3TextFrame, IPLS:ID3TextFrame, COMM:ID3TextFrame, USLT:ID3TextFrame,
							USER:ID3TextFrame};
		public static const FRAME_ARGS:Object = {
							PRIV:[true,false], UFID:[true,false], MCDI:[false,false], SYTC:[false,true],
							EQUA:[false,true], GRID:[true,true],  ENCR:[true,true],   POSS:[false,true],
							POPM:[true,true],  PCNT:[false,false],
							WXXX:[false,true], IPLS:[false,false], COMM:[true,true],  USLT:[true,true],
							USER:[true,false]};
		public static const UNSYNCHRONIZED:int = 0x80;
		public static const EXTENDED_HEADER:int = 0x40;
		public static const EXPERIMENTAL:int = 0x20;
		public static const EXT_HEADER_CRC32:int = 0x8000;
		
		private var frames:Object;
		private var framesAvail:Array;
		public var version:uint;
		public var revision:uint;
		public var flags:uint;
		public var length:int;
		public var exportData:ByteArray;
		private var extHeader:ExtendedHeader;
		
		public function ID3v2(v:int=3,r:int=0){
			version = v;
			revision = r;
			frames = new Object();
			framesAvail = new Array();
			flags = UNSYNCHRONIZED;
		}
		private var _f:int,_fa:int;
		public function nextFrame():ID3v2Frame{
			if(_fa >= framesAvail.length) {_f=0;_fa=0;return null;}
			var s:String = framesAvail[_fa];
			if(!s){_f=0;_fa=0;return null;}
			var o = frames[s];
			if(!o){_f=0;_fa=0;return null;}
			if(o is Array){
				_f++;
				if(_f < o.length) return o[_f];
				else { 
					_f = -1;
					_fa++;
					return nextFrame();
				}
			}else{_fa++; return o;}
		}
		public function addExtendedHeader(flags:uint,padding:uint=0):void{
			if(flags|padding){
				extHeader = new ExtendedHeader();
				extHeader.padding = padding;
				extHeader.flags = flags;
				flags |= EXTENDED_HEADER;
			}
		}
		public function removeExtendedHeader():void{ extHeader = null; flags &= ~EXTENDED_HEADER;}
		public function export():ByteArray{
			if(framesAvail.length == 0) return null;
			var ba:ByteArray = createHeader();
			var bp:ByteArray;
			if(flags&EXTENDED_HEADER){
				if(extHeader){
					ba.writeBytes(createExtHeader());
				} else flags &= ~EXTENDED_HEADER;
			}
			for each(var st:String in framesAvail){
				var cont = frames[st];
				if(cont is Array){
					for each (var t:ID3v2Frame in cont){
						bp = t.export();
						if(bp) ba.writeBytes(bp);
					}
				} else if(cont is ID3v2Frame){
					bp = cont.export()
					if(bp) ba.writeBytes(bp);
				}
			}
			if(flags&EXTENDED_HEADER){
				ba.position = 20;
				extHeader.crc = CRC32.generate(ba);
				ba.position = 16;
				ba.writeUnsignedInt(extHeader.crc);
			}
			if(flags&UNSYNCHRONIZED){ ba.position = 10; unsync(ba); }
			if(flags&EXTENDED_HEADER){
				ba.position = ba.length;
				for(var i:int =0; i < extHeader.padding; i++) ba.writeByte(0);
			}
			ba.position = 6;
			var len:int = ba.length - 10;
			ba.writeByte((len>>21)&0x7F);
			ba.writeByte((len>>14)&0x7F);
			ba.writeByte((len>>7)&0x7F);
			ba.writeByte(len&0x7F);
			this.length = len;
			this.exportData = ba;
			return ba;
		}
		public function getFrame(ID:String):*{
			if(frames.hasOwnProperty(ID))
				return frames[ID];
			else return null;
		}
		public function addFrame(fr:ID3v2Frame):void{
			if(fr.ID == null) return;
			var old;
			if(frames.hasOwnProperty(fr.ID)) old = frames[fr.ID];
			if(old != null){
				if(old is Array) old.push(fr);
				else frames[fr.ID] = [old, fr];
			} else { 
				frames[fr.ID] = fr;
				framesAvail.push(fr.ID);
			}
		}
		private function createHeader():ByteArray{
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes("ID3");
			if(version == 0xFF) version = 3;
			if(revision == 0xFF) revision = 0;
			ba.writeByte(version);
			ba.writeByte(revision);
			ba.writeByte(flags&0xE0);
			ba.writeInt(0);
			return ba;
		}
		private function createExtHeader():ByteArray{
			var ba:ByteArray = new ByteArray();
			if(extHeader.flags&EXT_HEADER_CRC32) extHeader.length = 10;
			else extHeader.length = 6;
			ba.writeInt(extHeader.length);
			ba.writeShort(extHeader.flags);
			ba.writeInt(extHeader.padding);
			if(extHeader.flags&EXT_HEADER_CRC32) ba.writeInt(0);
			return ba;
		}
		private function unsync(ba:ByteArray):void{
			var len:int = ba.bytesAvailable;
			var needToUnsync:Boolean = false;
			for(var i:int = 0; i < len; i++){
				if(ba.readUnsignedByte() == 0xFF){
					if(ba.readUnsignedByte()>>5 == 7){ needToUnsync = true; break; }
				}
			}
			if(needToUnsync){
				ba.position = ba.length - len;
				var t:uint;
				var p:int;
				for(i = 0; i < len; i++){
					if(ba.readUnsignedByte() == 0xFF){
						t = ba.readUnsignedByte();
						if(t == 0 || t>>5 == 7){
							p = ba.position;
							var bp:ByteArray = new ByteArray();
							ba.readBytes(bp);
							ba.position = p;
							ba.writeByte(0);
							ba.writeBytes(bp);
						}
					}
				}
				ba.position = ba.length - 1;
				if(ba.readUnsignedByte() == 0xFF){
					ba.writeByte(0);
				}
			} else {
				flags &= ~UNSYNCHRONIZED;
				ba.position = 5;
				ba.writeByte(flags&0xE0);
			}
		}
		public static function id3v1to2(id1:ID3v1):ID3v2{
			var id3 = new ID3v2(3,0);
			var tit:ID3TextFrame;
			if(id1.title)  { tit = new ID3TextFrame("TIT2"); tit.content = id1.title;   id3.addFrame(tit); }
			if(id1.artist) { tit = new ID3TextFrame("TPE1"); tit.content = id1.artist;  id3.addFrame(tit); }
			if(id1.album)  { tit = new ID3TextFrame("TALB"); tit.content = id1.album;   id3.addFrame(tit); }
			if(id1.comment){ tit = new ID3TextFrame("COMM"); tit.content = id1.comment; id3.addFrame(tit); }
			if(id1.genre>=0){tit = new ID3TextFrame("TCON"); tit.content = "("+id1.genre+")"; id3.addFrame(tit); }
			if(id1.year)   { tit = new ID3TextFrame("TYER"); tit.content = id1.year;    id3.addFrame(tit); }
			return id3;
		}
		
		public static function parse(data:ByteArray):ID3v2 {
			if(data.readUTFBytes(3) != 'ID3') return null;
			var currByte:uint;
			var id3 = new ID3v2(data.readUnsignedByte(),data.readUnsignedByte());
			id3.flags = data.readUnsignedByte();
			id3.length = data.readUnsignedByte() << 21;
			id3.length |= data.readUnsignedByte() << 14;
			id3.length |= data.readUnsignedByte() << 7;
			id3.length |= data.readUnsignedByte();
			var end:int = 10 + id3.length;
			if(id3.flags&UNSYNCHRONIZED){
				while(data.position < end){
					if(data.readUnsignedByte() == 0xFF && data.readUnsignedByte() == 0){
						var tmp = new ByteArray();
						var p:int = data.position - 1;
						data.readBytes(tmp,0,end - data.position);
						data.position = p;
						data.writeBytes(tmp);
						data.writeByte(0);
						data.position = p;
					}
				}
				data.position = 10;
			}
			if(id3.flags&EXTENDED_HEADER){
				id3.extHeader = new ExtendedHeader();
				id3.extHeader.length = data.readUnsignedInt();//len should be 6 or 10 (if crc32)
				id3.extHeader.flags = data.readUnsignedShort();
				id3.extHeader.padding = data.readUnsignedInt();
				if(id3.extHeader.flags & EXT_HEADER_CRC32) id3.extHeader.crc = data.readUnsignedInt();
			}
			//FRAMES
			var currFrame:ID3v2Frame;
			while (data.position < end){
				currByte = data.readUnsignedByte();
				if(currByte < 0x30 || currByte > 0x5A) continue;
				currByte = data.readUnsignedByte();
				if(currByte < 0x30 || currByte > 0x5A) continue;
				currByte = data.readUnsignedByte();
				if(currByte < 0x30 || currByte > 0x5A) continue;
				currByte = data.readUnsignedByte();
				if(currByte < 0x30 || currByte > 0x5A) continue;
				data.position -= 4;
				var idd:String = data.readUTFBytes(4);
				switch(idd.substring(0,1)){
					case "T":   currFrame = new ID3TextFrame(idd); break;
					case "W":   if(idd=="WXXX") currFrame = new ID3TextFrame(idd,FRAME_ARGS[idd]);
								else currFrame = new ID3MultiFrame(idd,[true,false]); 
								break;
					default:	if(FRAME_CLASSES.hasOwnProperty(idd))
									currFrame = new FRAME_CLASSES[idd](idd,FRAME_ARGS[idd]);
								else currFrame = new ID3v2Frame(idd);
				}
				currFrame.length = data.readUnsignedInt();
				currFrame.flags = data.readUnsignedShort();
				currFrame.data = new ByteArray();
				if(currFrame.length) data.readBytes(currFrame.data,0,currFrame.length);
				currFrame.data.position = 0;
				trace(currFrame.ID,currFrame.length,currFrame.flags,currFrame.data.length);
				id3.addFrame(currFrame);
			}
			return id3;
		}
	}
}
final class ExtendedHeader{
	var length:int;
	var flags:uint;
	var padding:uint;
	var crc:uint;
}