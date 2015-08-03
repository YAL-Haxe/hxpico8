package;
#if !macro
/**
 * ...
 * @author YellowAfterlife
 */
@:final class String {
	public var length(get, never):Int;
	@:extern inline function get_length():Int return Pico.strlen(this);
	/// Returns a character at a 0-based index
	public function charAt(i:Int) return lcharAt(i + 1);
	
	/// Returns a character at a 1-based index
	public function lcharAt(i:Int) return Pico.sub(this, i, i);
	/// Returns a part of string at a 1-based index
	@:extern public inline function lsubstring(start:Int, ?end:Int) return Pico.sub(this, start, end);
}
#else
@:coreApi extern class String {
	var length(default,null) : Int;

	function new(string:String) : Void;
	function toUpperCase() : String;
	function toLowerCase() : String;
	function charAt( index : Int) : String;
	function indexOf( str : String, ?startIndex : Int ) : Int;
	function lastIndexOf( str : String, ?startIndex : Int ) : Int;
	function split( delimiter : String ) : Array<String>;
	function toString() : String;
	function substring( startIndex : Int, ?endIndex : Int ) : String;

	inline function charCodeAt( index : Int) : Null<Int> {
		return untyped HxOverrides.cca(this, index);
	}

	inline function substr( pos : Int, ?len : Int ) : String {
		return untyped HxOverrides.substr(this, pos, len);
	}

	static function fromCharCode( code : Int ) : String;
}
#end