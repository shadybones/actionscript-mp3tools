////////////IN GENERAL, NOT TESTED VERY WELL
////////////ALPHA VERSION
////////////USE AT YOUR OWN DISCRETION - LICENSE & INFO: http://code.google.com/p/actionscript-mp3tools/
////////////Author: Jordan Williams
////////////Web: http://quixological.com
////////////Work: http://shadybones.elance.com

package org.outertia.audio.ID3 {
	import flash.utils.ByteArray;
	public class ID3v1 {
		public static const GENRE_LIST:Array = [
			"Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", "Grunge",
			"Hip-Hop", "Jazz", "Metal", "New Age", "Oldies", "Other", "Pop", "R&B",
			"Rap", "Reggae", "Rock", "Techno", "Industrial", "Alternative", "Ska",
			"Death Metal", "Pranks", "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop",
			"Vocal", "Jazz+Funk", "Fusion", "Trance", "Classical", "Instrumental",
			"Acid", "House", "Game", "Sound Clip", "Gospel", "Noise", "Alternative Rock",
			"Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop",
			"Instrumental Rock", "Ethnic", "Gothic", "Darkwave", "Techno-Industrial",
			"Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern Rock", "Comedy",
			"Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk", "Jungle",
			"Native US", "Cabaret", "New Wave", "Psychedelic", "Rave",
			"Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz",
			"Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock", "Folk",
			"Folk-Rock", "National Folk", "Swing", "Fast Fusion", "Bebob", "Latin",
			"Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock",
			"Progressive Rock", "Psychedelic Rock", "Symphonic Rock", "Slow Rock",
			"Big Band", "Chorus", "Easy Listening", "Acoustic", "Humour", "Speech",
			"Chanson", "Opera", "Chamber Music", "Sonata", "Symphony", "Booty Bass",
			"Primus", "Porn Groove", "Satire", "Slow Jam", "Club", "Tango", "Samba",
			"Folklore", "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle", "Duet",
			"Punk Rock", "Drum Solo", "A Cappella", "Euro-House", "Dance Hall",
			"Goa", "Drum & Bass", "Club-House", "Hardcore", "Terror", "Indie",
			"BritPop", "Negerpunk", "Polsk Punk", "Beat", "Christian Gangsta",
			"Heavy Metal", "Black Metal", "Crossover", "Contemporary Christian",
			"Christian Rock", "Merengue", "Salsa", "Thrash Metal", "Anime", "JPop","SynthPop"];
		public static function genreByName(name:String):int{
			var len:int = GENRE_LIST.length;
			for(var i:int = 0; i < len; i++){
				if(GENRE_LIST[i] == name) return i;
			}
			return -1;
		}
		
		public var artist:String;
		public var album:String;
		public var title:String;
		public var year:String;
		public var comment:String;
		public var genre:int;
		public function ID3v1(t:String,a:String,abm:String,yr:String,comm:String,g:int=-1){
			artist = a;
			album = abm;
			title = t;
			year = yr;
			comment = comm;
			genre = g;
		}
		public function export():ByteArray{
			var bytearray:ByteArray = new ByteArray();
			bytearray.writeUTFBytes('TAG');
			if(!title) title = "";if(!artist) artist = "";if(!album) album = "";
			if(!year) year = "";if(!comment) comment = "";
			while(title.length < 30) title += " ";
			while(artist.length < 30) artist += " ";
			while(album.length < 30) album += " ";
			while(year.length < 4) year += " ";
			while(comment.length < 30) comment += " ";
			while(title.length < 30) title += " ";
			bytearray.writeUTFBytes(title.substring(0,30));
			bytearray.writeUTFBytes(artist.substring(0,30));
			bytearray.writeUTFBytes(album.substring(0,30));
			bytearray.writeUTFBytes(year.substring(0,4));
			bytearray.writeUTFBytes(comment.substring(0,30));
			bytearray.writeByte(genre&0xFF);
			return bytearray;
		}
	}
}