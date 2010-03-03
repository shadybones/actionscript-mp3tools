////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio.ID3 {
	import org.outertia.audio.ID3.ID3v2Frame;
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
			if(!ID || !_data || _data.length==0) return null;
			if(content && content.length) return content; 
			else if(info && info.length) return info;
			else if (hbyte && byte) return byte;
			else _data.position = 0;
			if(htext){
				info = _data.readUTFBytes(_data.bytesAvailable);
				_data.position = info.length;
				if(_data.bytesAvailable) _data.readByte();
			}
			if(hbyte){
				if(_data.bytesAvailable) byte = _data.readUnsignedByte();
			}
			if(_data.bytesAvailable){
				_data.readBytes(content,0,_data.bytesAvailable); 
			} else{
				if(htext) return info;
				else if(hbyte) return byte;
			}
			hasParsedData = true;
			return content;
		}
		override protected function formatData():void{
			_data = new ByteArray();
			if(htext) { writeUTFBytes(info); _data.writeByte(0); }
			if(hbyte) _data.writeByte(byte);
			content.position=0;
			content.readBytes(_data);
		}
	}
}