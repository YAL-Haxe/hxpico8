package js;

/**
 * ...
 * @author YellowAfterlife
 */
extern class Boot {
	private static function __unhtml(s:String):String;
	private static function __trace(v:Dynamic, i:haxe.PosInfos):Void;
	private static function __clear_trace():Void;
	static function isClass(o:Dynamic):Bool;
	static function isEnum(e:Dynamic):Bool;
	static function getClass(o:Dynamic):Dynamic;
	@:ifFeature("has_enum") private static function __string_rec(o:Dynamic, s:String):String;
	private static function __interfLoop(cc:Dynamic, cl:Dynamic):Bool;
	@:ifFeature("typed_catch") private static function __instanceof(o:Dynamic, c:Dynamic):Bool;
	@:ifFeature("typed_cast") private static function __cast(o:Dynamic, t:Dynamic):Dynamic;
	static var __toStr;
	static function __nativeClassName(o:Dynamic):String;
	static function __isNativeObj(o:Dynamic):Bool;
	static function __resolveNativeClass(name:String):Dynamic;
}

private extern class HaxeError extends js.Error {
	var val:Dynamic;
	public function new(val:Dynamic);
}