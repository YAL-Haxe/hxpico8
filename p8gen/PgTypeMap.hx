package p8gen;
import haxe.macro.Type;
import p8gen.struct.PgType;

/**
 * ...
 * @author YellowAfterlife
 */
abstract PgTypeMap<T>(Map<String, Map<String, T>>) from Map<String, Map<String, T>> to Map<String, Map<String, T>> {
	public inline function new() {
		this = new Map();
	}
	public inline function exists(module:String, name:String):Bool {
		var map = this.get(module);
		return map != null ? map.exists(name) : false;
	}
	public inline function get(module:String, name:String):T {
		var map = this.get(module);
		return map != null ? map[name] : null;
	}
	public inline function set(module:String, name:String, value:T):Void {
		var map = this.get(module);
		if (map == null) this[module] = map = new Map();
		map[name] = value;
	}
	public inline function baseGet(t:BaseType):T {
		return get(t.module, t.name);
	}
	public inline function baseSet(t:BaseType, v:T):Void {
		set(t.module, t.name, v);
	}
	public inline function wrapGet(t:PgType):T {
		return get(t.module, t.name);
	}
	public inline function wrapSet(t:PgType, v:T):Void {
		set(t.module, t.name, v);
	}
	public inline function keys() return this.keys();
}
