package;

@:noDoc
extern class HxOverrides {
	static function dateStr( date :Date ) : String;
	static function strDate( s : String ) : Date;
	static function cca( s : String, index : Int ) : Null<Int>;
	static function substr( s : String, pos : Int, ?len : Int ) : String;
	static function indexOf<T>( a : Array<T>, obj : T, i : Int) : Void;
	static function lastIndexOf<T>( a : Array<T>, obj : T, i : Int) : Void;
	static function remove<T>( a : Array<T>, obj : T ) : Void;
	static function iter<T>( a : Array<T> ) : Iterator<T>;
	
}