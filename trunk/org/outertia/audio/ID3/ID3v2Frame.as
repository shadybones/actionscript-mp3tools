////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio.ID3 {
	import flash.utils.ByteArray;
	public class ID3v2Frame {
		public static const ENCRYPTED:uint = 0x40;
		public static const COMPRESSED:uint = 0x80;
		public static const GROUP:uint = 0x20;
		public static const TAG_ALTERATION:uint = 0x8000;
		public static const FILE_ALTERATION:uint = 0x4000;
		public static const READ_ONLY:uint = 0x2000;
		
		public var length:int = 0;
		public var flags:uint = 0;
		protected var _data:ByteArray;
		public var dataReturnOffset:int = 0;
		public var encoding:uint = 0;
		protected var hasParsedData:Boolean = false;
		
		public function set data(ba:ByteArray):void{ _data = ba; this.value(); }
		public function get data():ByteArray{ return _data; }
		
		protected var _ID:String;
		public function get ID():String { return _ID; }
		public function set ID(id:String):void{ 
			var regx = /[A-Z0-9]{4}/;
			if(id.search(regx) == 0) _ID = id.substring(0,4);
		}
		
		public function ID3v2Frame(id:String){
			this.ID = id;
		}
		
		////////  Extrapolates and returns expected data based on frame type.
		////////  Should be overridden in subclasses.
		public function value():*{
			if(!_ID || !_data || length==0) return null;
			data.position = dataReturnOffset;
			return readUTFBytesFull();
		}
		////////  opposite of value() - prepares data for export to ID3 tag.
		////////  Must be overridden in subclasses.
		protected function formatData():void{
			if(!_data) _data = new ByteArray(); 
			trace("creating new data");
		}
		
		protected function writeUTFBytes(st:String):void{
			if(st && st.length){
				trace(st);
				_data.writeUTFBytes(st);
			}
		}
		protected function readUTFBytesFull(len:uint=0):String{
			var startpos:uint = _data.position;
			if(len==0) len = _data.length;
			else len += _data.position;
			var returnme:String = "";
			var re:String;
			for(var i:int = _data.position; i < len ; i++){
				_data.position = i;
				re= _data.readUTFBytes(len - i);
				i += re.length;
				returnme += re;
			}
			_data.position = startpos + returnme.length;
			return returnme;
		}
		final public function export():ByteArray{
			if(!_ID) return null;
			//if( data && !hasParsedData ) this.value();
			//if( !data || data.length < 2 || hasParsedData ) 
			this.formatData();
			trace(_data.length,"data length in export");
			//if(data.length < 2) return null; //was 8, why??
			var tmp:ByteArray = createHeader();
			tmp.writeBytes(_data);
			return tmp;
		}
		final private function createHeader():ByteArray{
			this.length = _data.length;
			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes(_ID);
			tmp.writeUnsignedInt(_data.length);
			tmp.writeShort(flags);
			return tmp;
		}
	}
}