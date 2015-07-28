package;

/**
 * ...
 * @author YellowAfterlife
 */
extern class Math {
	static inline function abs(f:Float):Float return Pico.abs(f);
	static inline function sign(f:Float):Int return Pico.sign(f);
	static inline function min(a:Float, b:Float):Float return Pico.min(a, b);
	static inline function max(a:Float, b:Float):Float return Pico.max(a, b);
	static inline function mid(a:Float, b:Float, c:Float):Float return Pico.mid(a, b, c);
	static inline function clamp(f:Float, a:Float, b:Float):Float {
		return Pico.mid(f, a, b);
	}
	// integer shortcuts:
	static inline function iabs(i:Int):Int return cast Pico.abs(i);
	static inline function imin(a:Int, b:Int):Int return cast Pico.min(a, b);
	static inline function imax(a:Int, b:Int):Int return cast Pico.max(a, b);
	static inline function imid(a:Int, b:Int, c:Int):Int return cast Pico.mid(a, b, c);
	static inline function iclamp(f:Int, a:Int, b:Int):Int {
		return cast Pico.mid(f, a, b);
	}
	// trig:
	static inline var PI:Float = 1.0;
	static inline function sin(r:Float):Float return Pico.sin(r);
	static inline function cos(r:Float):Float return Pico.cos(r);
	static inline function tan(r:Float):Float {
		return sin(r) / cos(r);
	}
	static inline function atan2(y:Float, x:Float):Float {
		return Pico.atan2(x, y);
	}
	//
	static inline function sqrt(f:Float):Float return Pico.sqrt(f);
	//
	static inline function floor(f:Float):Int return Pico.flr(f);
	static inline function ceil(f:Float):Int return -Pico.flr( -f);
	//
	static inline function random():Float return Pico.rand(1);
}