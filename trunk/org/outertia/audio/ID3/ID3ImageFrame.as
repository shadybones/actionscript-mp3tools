////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio.ID3 {
	import org.outertia.core.JPEGEncoder;  ////////////////<-------must change this to your jpg encoder, and fit the encode statements at the bottom
	import org.outertia.core.PNGEncoder;  ///////////////<--------must change this to your png encoder, and fit the encode statements at the bottom
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import org.outertia.audio.ID3.ID3v2Frame;
	
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
			if(!ID || !_data || _data.length==0) return null;
			if(file) return file;
			else _data.position = 0;
			encoding = _data.readUnsignedByte();
			
			var orig:uint = _data.position;
			format = _data.readUTFBytes(_data.bytesAvailable);
			_data.position = orig + format.length + 1;
			if(format.lastIndexOf("/") > 0) format = format.substring(format.lastIndexOf("/")+1);
			
			type = _data.readUnsignedByte();
			
			var pos:uint;
			if(encoding) { 
				_data.readUnsignedByte(); _data.readUnsignedByte(); 
				orig = _data.position;
				while(_data.bytesAvailable && _data.readUnsignedShort() != 0){}
				if(!_data.bytesAvailable) pos = _data.position;
				else pos = _data.position-2;
				description = ""; 
				_data.position = orig;
				for(var i:int = orig; i < pos; i++){
					description += _data.readUTFBytes(1);
				}
				if(_data.bytesAvailable) _data.readByte(); 
				if(_data.bytesAvailable) _data.readByte();
			}else{
				orig = _data.position;
				description = _data.readUTFBytes(_data.bytesAvailable);
				_data.position = orig + description.length + 1;
			}
			
			var ba:ByteArray = new ByteArray();
			_data.readBytes(ba);
			file = ba;
			hasParsedData = true;
			return ba.length;
		}
		override protected function formatData():void{
			_data = new ByteArray();
			if(!image) return;
			_data.writeByte(0);//encoding
			var st:String = "image/";
			if(format.lastIndexOf("/") < 0) st += format;
			else st = format;
			writeUTFBytes(st);
			_data.writeByte(0);
			_data.writeByte(type);
			writeUTFBytes(description);
			_data.writeByte(0);
			if(format == PNG){
				var png:ByteArray = PNGEncoder.encode(image,(image.transparent?0:1));
				_data.writeBytes(png);
			}else { //format == JPEG
				var jpg = new JPEGEncoder(jpgQuality);
				var jpga:ByteArray = jpg.blockingEncode(image);
				_data.writeBytes(jpga);
			}
		}
		
	}
}