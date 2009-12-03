package mine.audio.ID3 {
	import mine.audio.ID3.ID3v2Frame;
	import flash.utils.ByteArray;
	
	//GOOD FOR: T---,WXXX,IPLS,COMM,USLT,USER
	public class ID3TextFrame extends ID3v2Frame {
		
		public var content:String = "";      //always the final text field
		public var description:String = "";  //always the second to last text field
		public var language:String = "";
		private var lingo:Boolean = false;
		private var disco:Boolean = false;
		
		public function ID3TextFrame(id:String, args:Array = null){
			super(id);
			if(args){ lingo = args[0]; disco = args[1]; }
		}
		override public function value():*{
			if(!ID || !data || length==0) return null;
			if(content && content.length) return content;
			data.position = 0;
			encoding = data.readUnsignedByte();
			if(lingo) language = data.readUTFBytes(3);
			
			var first:String;
			var pos:uint;
			var orig:uint;
			if(data.bytesAvailable) orig = data.readUnsignedByte();
			else return "";
			if(orig == 255){
				if(data.bytesAvailable) data.readByte();
				else return "";
				orig = data.position;
				while(data.bytesAvailable && data.readUnsignedShort() != 0){}
				if(!data.bytesAvailable) pos = data.position;
				else pos = data.position-2;
				first = ""; 
				data.position = orig;
				for(var i:int = orig; i < pos; i++){
					first += data.readUTFBytes(1);
				}
				if(data.bytesAvailable) data.readByte(); 
				if(data.bytesAvailable) data.readByte();
			} else{
				data.position--;
				orig = data.position;
				first = data.readUTFBytes(data.bytesAvailable);
				data.position = orig + first.length;
				if(data.bytesAvailable) data.readByte();
			}
			if(!data.bytesAvailable){
				content = ""+first;
				return content;
			} else description = first;
			
			orig = data.readUnsignedByte();
			if(orig == 255){
				if(data.bytesAvailable) data.readByte();
				else return "";
				orig = data.position;
				while(data.bytesAvailable && data.readUnsignedShort() != 0){}
				if(!data.bytesAvailable) pos = data.position;
				else pos = data.position-2;
				content = "";
				data.position = orig;
				for(i = orig; i < pos; i++){
					content += data.readUTFBytes(1);
				}
				return content;
			} else{
				data.position--;
				content = ""+data.readUTFBytes(data.bytesAvailable);
				return content;
			}
		}
		private function formatData():void{
			data = new ByteArray();
			data.writeByte(0);//encoding
			if(lingo){
				if(language && language.length > 2) writeUTFBytes(language.substring(0,3));
				else writeUTFBytes("eng");
			}
			if(disco){ 
				writeUTFBytes(description); 
				data.writeByte(0); 
			}
			writeUTFBytes(content);
		}
	}
}