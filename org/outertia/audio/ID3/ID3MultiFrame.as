package mine.audio.ID3 {
	import mine.audio.ID3.ID3v2Frame;
	import flash.utils.ByteArray;
	
	//GOOD FOR: W---,PRIV,UFID,MCDI,SYTC,EQUA,GRID,ENCR,POPM,PCNT,POSS
	public class ID3MultiFrame extends ID3v2Frame {
		
		public var content:ByteArray;
		public var info:String = "";
		public var byte:uint = 0;
		private var htext:Boolean;
		private var hbyte:Boolean;
		
		public function ID3MultiFrame(id:String, args:Array){
			super(id);
			if(args){ htext = args[0]; hbyte = args[1]; }
			content = new ByteArray();
		}
		override public function value():*{
			if(!ID || !data || length==0) return null;
			if(content && content.length) return content; 
			else if(info && info.length) return info;
			else if (hbyte && byte) return byte;
			else data.position = 0;
			if(htext){
				info = data.readUTFBytes(data.bytesAvailable);
				data.position = info.length;
				if(data.bytesAvailable) data.readByte();
			}
			if(hbyte){
				if(data.bytesAvailable) byte = data.readUnsignedByte();
			}
			if(data.bytesAvailable){
				data.readBytes(content,0,data.bytesAvailable); 
			} else{
				if(htext) return info;
				else if(hbyte) return byte;
			}
			return content;
		}
		private function formatData():void{
			data = new ByteArray();
			if(htext) { writeUTFBytes(info); data.writeByte(0); }
			if(hbyte) data.writeByte(byte);
			content.position=0;
			content.readBytes(data);
		}
	}
}