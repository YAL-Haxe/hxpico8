package;

/**
 * ...
 * @author YellowAfterlife
 */
@:native("")
extern class Pico {
	//{ events
	@:native("_update") static var onUpdate:Void->Void;
	/// executed on game draw. onUpdate must be defined for it to work.
	@:native("_draw") static var onDraw:Void->Void;
	/// executed on game start. Most often you don't need this one.
	@:native("_init") static var onInit:Void->Void;
	//}
	//{ system
	/// Returns:
	/// mode 0: memory usage (0...256)
	/// mode 1: CPU usage (0..1)
	static function stat(mode:Int):Fixed;
	static function flip():Void;
	static function time():Fixed;
	//}
	//{ sprites
	/// Gets the color of a spritesheet pixel at the given coordinates.
	static function sget(x:Fixed, y:Fixed):Int;
	/// Sets the color of a spritesheet pixel at the given coordinates.
	/// If color is not specified, the current color is used.
	static function sset(x:Fixed, y:Fixed, ?color:Int):Void;
	/// Returns the value of sprite's flag.
	static function fget(sprite:Int, flag:Int):Bool;
	/// Returns sprite's flags as bits
	@:native("fget") static function fgetx(sprite:Int):Int;
	/// Changes the value of sprite's flag
	static function fset(sprite:Int, flag:Int, value:Bool):Void;
	/// Changes sprite's flags.
	@:native("fset") static function fsetx(sprite:Int, flagBits:Int):Void;
	//}
	//{ colors
	static inline var clBlack = 0;
	static inline var clDarkBlue = 1;
	static inline var clDarkPurple = 2;
	static inline var clDarkGreen = 3;
	static inline var clBrown = 4;
	static inline var clDarkGray = 5;
	static inline var clLightGray = 6;
	static inline var clWhite = 7;
	static inline var clRed = 8;
	static inline var clOrange = 9;
	static inline var clYellow = 10;
	static inline var clGreen = 11;
	static inline var clBlue = 12;
	static inline var clIndigo = 13;
	static inline var clPink = 14;
	static inline var clPeach = 15;
	//}
	//{ drawing
	
	/// Clears the screen.
	static function cls():Void;
	
	/// Sets the screen offset for all subsequent drawing operations.
	/// Call without arguments to reset to default (0, 0).
	static function camera(?x:Fixed, ?y:Fixed):Void;
	
	/// Sets the screen's clipping region in pixels.
	/// Call without arguments to reset.
	static function clip(x:Int, y:Int, w:Int, h:Int):Void;
	
	/// Sets the default color for the drawing operations
	static function color(color:Int):Void;
	
	/// Gets the color of a pixel at the given screen coordinates.
	static function pget(x:Fixed, y:Fixed):Int;
	
	/// Sets the color of a pixel at the given screen coordinates.
	/// If color is not specified, the current color is used.
	static function pset(x:Fixed, y:Fixed, ?color:Int):Void;
	
	/// Replaces all instances of color_from by color_to in the subsequent draw calls.
	/// Call pal() without arguments to reset to system defaults.
	/// If specified, palette determines the palette to switch colors in:
	/// 0: draw palette (default) - colors are remapped on draw (for example, to re-color sprites)
	/// 1: screen palette - colors are remapped on display (for example, to achive fading or global color transitions).
	static function pal(?from:Int, ?to:Int, ?palette:Int):Void;
	
	/// Changes whether a particular color should be drawn (affects spr, sspr, map).
	/// For example, palt(8, false) will disable drawing of red pixels.
	/// Calling this function with no arguments will reset state to default, where all colors but black (#0) are drawn.
	static function palt(?color:Int, visible:Bool):Void;
	
	//
	
	/// Sets the cursor position and carriage return margin.
	static function cursor(x:Fixed, y:Fixed):Void;
	
	/// Prints a string.
	/// If only first argument is supplied, and the cursor reaches the end of the screen, a carriage return and vertical scroll is automatically applied. (terminal-like behaviour)
	static function print(value:Dynamic, ?x:Fixed, ?y:Fixed, ?color:Int):Void;
	//
	static function line(x1:Fixed, y1:Fixed, x2:Fixed, y:Fixed, ?color:Int):Void;
	static function circ(x:Fixed, y:Fixed, r:Fixed, ?color:Int):Void;
	static function circfill(x:Fixed, y:Fixed, r:Fixed, ?color:Int):Void;
	static function rect(x1:Fixed, y1:Fixed, x2:Fixed, y:Fixed, ?color:Int):Void;
	static function rectfill(x1:Fixed, y1:Fixed, x2:Fixed, y:Fixed, ?color:Int):Void;
	static function spr(sprite:Fixed, x:Fixed, y:Fixed, ?cols:Fixed, ?rows:Fixed, ?flip:Bool):Void;
	static function sspr(left:Fixed, top:Fixed, width:Fixed, height:Fixed, x:Fixed, y:Fixed, ?dw:Int, ?dh:Int, ?flip:Bool):Void;
	static function map(col:Fixed, row:Fixed, x:Fixed, y:Fixed, ?cols:Fixed, ?rows:Fixed, ?flags:Int):Void;
	//}
	//{ collections
	/// Converts 0-based declaration into 1-based declaration
	static function collection<T>(values:Array<T>):Collection<T>;
	static function add<T>(co:Collection<T>, value:T):Void;
	static function del<T>(co:Collection<T>, value:T):Void;
	static function count<T>(co:Collection<T>):Int;
	@:native("foreach") static function forEach<T>(co:Collection<T>, func:T->Void):Void;
	static function all<T>(co:Collection<T>):Iterator<T>;
	//}
	//{ input
	static inline var btLeft:Int = 0;
	static inline var btRight:Int = 1;
	static inline var btUp:Int = 2;
	static inline var btDown:Int = 3;
	static inline var btA:Int = 4;
	static inline var btB:Int = 5;
	/// Returns whether the given button is down.
	static function btn(index:Int, ?player:Int):Bool;
	/// Returns whether the given button was pressed (includes "auto-fire")
	static function btnp(index:Int, ?player:Int):Bool;
	//}
	//{ audio
	static function sfx(sound:Int, ?channel:Int, ?offset:Fixed):Void;
	static function music(?pattern:Int, ?fade:Fixed, ?channelMask:Int):Void;
	//}
	//{ map
	static function mget(col:Fixed, row:Fixed):Int;
	static function mset(col:Fixed, row:Fixed, sprite:Int):Void;
	//}
	//{ memory
	static function peek(adr:Int):Int;
	static function poke(adr:Int, byte:Int):Int;
	static function memcpy(dest:Int, src:Int, len:Int):Void;
	static function memset(dest:Int, byte:Int, len:Int):Void;
	static function reload(dest:Int, src:Int, len:Int):Void;
	static function cstore(?dest:Int, ?src:Int, ?len:Int):Void;
	//}
	//{ math
	static function sub(s:String, from:Int, ?to:Int):String;
	@:native("`length") static function strlen(s:String):Int;
	static function flr(x:Fixed):Int;
	static function abs(x:Fixed):Fixed;
	@:native("sgn") static function sign(x:Fixed):Int;
	static function sqrt(x:Fixed):Fixed;
	static function max(x:Fixed, y:Fixed):Fixed;
	static function min(x:Fixed, y:Fixed):Fixed;
	static function mid(x:Fixed, y:Fixed, z:Fixed):Fixed;
	static function cos(x:Fixed):Fixed;
	static function sin(x:Fixed):Fixed;
	static function atan2(x:Fixed, y:Fixed):Fixed;
	/// Returns a random number between 0 (incl.) and x (excl.)
	@:native("rnd") static function rand(x:Fixed):Fixed;
	static function srand(seed:Int):Void;
	/// maps to Lua' arithmetic loop.
	static function loop(from:Fixed, to:Fixed, step:Fixed = 1):Iterator<Fixed>;
	///
	@:native("loop") static function iloop(from:Int, to:Int, step:Int = 1):Iterator<Int>;
	//}
}