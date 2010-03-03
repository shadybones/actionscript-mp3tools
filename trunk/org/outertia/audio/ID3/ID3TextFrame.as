////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio.ID3 {
	import org.outertia.audio.ID3.ID3v2Frame;
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
			if(!ID || !_data || _data.length == 0) return null;
			if(content && content.length) return content;
			_data.position = 0;
			encoding = _data.readUnsignedByte();
			if(lingo) language = _data.readUTFBytes(3);
			hasParsedData = true;
			var first:String;
			var pos:uint;
			var orig:uint;
			if(_data.bytesAvailable) orig = _data.readUnsignedByte();
			else return "";
			if(orig == 255){
				if(_data.bytesAvailable) _data.readByte();
				else return "";
				orig = _data.position;
				while(_data.bytesAvailable && _data.readUnsignedShort() != 0){}
				if(!_data.bytesAvailable) pos = _data.position;
				else pos = _data.position-2;
				first = ""; 
				_data.position = orig;
				for(var i:int = orig; i < pos; i++){
					first += _data.readUTFBytes(1);
				}
				if(_data.bytesAvailable) _data.readByte(); 
				if(_data.bytesAvailable) _data.readByte();
			} else{
				_data.position--;
				orig = _data.position;
				first = _data.readUTFBytes(_data.bytesAvailable);
				_data.position = orig + first.length;
				if(_data.bytesAvailable) _data.readByte();
			}
			if(!_data.bytesAvailable){
				if(_ID=="COMM") description = ""+first;
				else content = ""+first;
				return content;
			} else description = first;
			
			orig = data.readUnsignedByte();
			if(orig == 255){
				if(_data.bytesAvailable) _data.readByte();
				else return "";
				orig = _data.position;
				while(_data.bytesAvailable && _data.readUnsignedShort() != 0){}
				if(!_data.bytesAvailable) pos = _data.position;
				else pos = _data.position-2;
				content = "";
				_data.position = orig;
				for(i = orig; i < pos; i++){
					content += _data.readUTFBytes(1);
				}
				return content;
			} else{
				_data.position--;
				content = ""+_data.readUTFBytes(_data.bytesAvailable);
				return content;
			}
		}
		override protected function formatData():void{
			var tmp = _data;
			_data = new ByteArray();
			_data.writeByte(0);//encoding
			if(lingo){
				if(language && language.length > 2) writeUTFBytes(language.substring(0,3));
				else writeUTFBytes("eng");
			}
			if(disco){ 
				writeUTFBytes(description); 
				_data.writeByte(0); 
			}
			writeUTFBytes(content);
			trace("formatting data in txtFrame");
			if(tmp){
				for(var i:int = 0; i < _data.length && i < tmp.length ; i++){
					trace(i,_data[i],tmp[i],(_data[i]==tmp[i]));
				}
			}
		}
		public function toString():String{
			var st:String = _ID+" tag. Content="+content+" hasLingo="+lingo+" hasDescr="+ disco+" hasParsedData="+hasParsedData;
			if(disco) st += " Descr="+description;
			if(lingo) st += " Lang="+language;
			if(hasParsedData) st+= " Data.length="+_data.length;
			return st;
		}
	}
}