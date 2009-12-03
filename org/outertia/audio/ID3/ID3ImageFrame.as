package mine.audio.ID3 {
	import mine.core.JPEGEncoder;
	import mine.core.PNGEncoder;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import mine.audio.ID3.ID3v2Frame;
	
	public class ID3ImageFrame extends ID3v2Frame {
		public static const JPEG:String = "jpeg";
		public static const PNG:String = "png";
		
		//public static const :int = ;
		
		public var description:String = "";
		public var image:BitmapData;
		public var format:String = "";
		public var type:int;
		public var jpgQuality:int = 50;
		public var file:ByteArray;
		public function ID3ImageFrame(id:String,img:BitmapData=null){
			super(id);
			image = img;
		}
		override public function value():*{
			if(!ID || !data || length==0) return null;
			if(file) return file;
			else data.position = 0;
			encoding = data.readUnsignedByte();
			
			var orig:uint = data.position;
			format = data.readUTFBytes(data.bytesAvailable);
			data.position = orig + format.length + 1;
			if(format.lastIndexOf("/") > 0) format = format.substring(format.lastIndexOf("/")+1);
			
			type = data.readUnsignedByte();
			
			var pos:uint;
			if(encoding) { 
				data.readUnsignedByte(); data.readUnsignedByte(); 
				orig = data.position;
				while(data.bytesAvailable && data.readUnsignedShort() != 0){}
				if(!data.bytesAvailable) pos = data.position;
				else pos = data.position-2;
				description = ""; 
				data.position = orig;
				for(var i:int = orig; i < pos; i++){
					description += data.readUTFBytes(1);
				}
				if(data.bytesAvailable) data.readByte(); 
				if(data.bytesAvailable) data.readByte();
			}else{
				orig = data.position;
				description = data.readUTFBytes(data.bytesAvailable);
				data.position = orig + description.length + 1;
			}
			
			var ba:ByteArray = new ByteArray();
			data.readBytes(ba);
			file = ba;
			return ba.length;
		}
		private function formatData():void{
			data = new ByteArray();
			if(!image) return;
			data.writeByte(0);//encoding
			var st:String = "image/";
			if(format.lastIndexOf("/") < 0) st += format;
			else st = format;
			writeUTFBytes(st);
			data.writeByte(0);
			data.writeByte(type);
			writeUTFBytes(description);
			data.writeByte(0);
			if(format == PNG){
				var png:ByteArray = PNGEncoder.encode(image,(image.transparent?0:1));
				data.writeBytes(png);
			}else { //format == JPEG
				var jpg = new JPEGEncoder(jpgQuality);
				var jpga:ByteArray = jpg.blockingEncode(image);
				data.writeBytes(jpga);
			}
		}
		
	}
}