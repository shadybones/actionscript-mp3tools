package mine.audio.ID3 {
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
		public var data:ByteArray;
		public var dataReturnOffset:int = 0;
		public var encoding:uint = 0;
		
		private var _ID:String;
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
			if(!_ID || !data || length==0) return null;
			data.position = dataReturnOffset;
			return readUTFBytesFull();
		}
		////////  opposite of value() - prepares data for export to ID3 tag.
		////////  Must be overridden in subclasses.
		private function formatData():void{
			data = new ByteArray();
		}
		
		public function writeUTFBytes(st:String):void{
			if(st && st.length){
				data.writeUTFBytes(st);
			}
		}
		public function readUTFBytesFull(len:uint=0):String{
			var startpos:uint = data.position;
			if(len==0) len = data.length;
			else len += data.position;
			var returnme:String = "";
			var re:String;
			for(var i:int = data.position; i < len ; i++){
				data.position = i;
				re= data.readUTFBytes(len - i);
				i += re.length;
				returnme += re;
			}
			data.position = startpos + returnme.length;
			return returnme;
		}
		final public function export():ByteArray{
			if(!_ID) return null;
			formatData();
			if(data.length < 8) return null;
			var tmp:ByteArray = createHeader();
			tmp.writeBytes(data);
			return tmp;
		}
		final private function createHeader():ByteArray{
			this.length = data.length;
			var tmp:ByteArray = new ByteArray();
			tmp.writeUTFBytes(_ID);
			tmp.writeUnsignedInt(data.length);
			tmp.writeShort(flags);
			return tmp;
		}
	}
}