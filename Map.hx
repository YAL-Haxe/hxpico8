package;
#if !macro
//{ Pico
/**
 * Map equivalent in GameMaker. No GC/ARC - call destroy() to free memory.
 * @author YellowAfterlife
 */
@:forward abstract Map<K, V>(Dynamic) {
	public inline function new() {
		this = { };
	}
	@:arrayAccess public inline function get(key:K):V {
		return untyped this[key];
	}
	public inline function set(key:K, value:V):Void {
		untyped this[key] = value;
	}
	@:arrayAccess public inline function arrayWrite(key:K, value:V):V {
		return untyped this[key] = value;
	}
}
//}
#elseif (haxe_ver >= 3.2)
//{ Haxe >= 3.2
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;
import haxe.ds.WeakMap;
import haxe.ds.EnumValueMap;
import haxe.Constraints.IMap;

@:multiType(K) abstract Map<K,V>(IMap<K,V> ) {
	public function new();
	public inline function set(key:K, value:V) this.set(key, value);
	@:arrayAccess public inline function get(key:K) return this.get(key);
	public inline function exists(key:K) return this.exists(key);
	public inline function remove(key:K) return this.remove(key);
	public inline function keys():Iterator<K> {
		return this.keys();
	}
	public inline function iterator():Iterator<V> {
		return this.iterator();
	}
	public inline function toString():String {
		return this.toString();
	}
	@:arrayAccess @:noCompletion public inline function arrayWrite(k:K, v:V):V {
		this.set(k, v);
		return v;
	}
	@:to static inline function toStringMap<K:String,V>(t:IMap<K,V>):StringMap<V> {
		return new StringMap<V>();
	}
	@:to static inline function toIntMap<K:Int,V>(t:IMap<K,V>):IntMap<V> {
		return new IntMap<V>();
	}
	@:to static inline function toEnumValueMapMap<K:EnumValue,V>(t:IMap<K,V>):EnumValueMap<K,V> {
		return new EnumValueMap<K, V>();
	}
	@:to static inline function toObjectMap<K:{ },V>(t:IMap<K,V>):ObjectMap<K,V> {
		return new ObjectMap<K, V>();
	}
	@:from static inline function fromStringMap<V>(map:StringMap<V>):Map< String, V > {
		return cast map;
	}
	@:from static inline function fromIntMap<V>(map:IntMap<V>):Map< Int, V > {
		return cast map;
	}
	@:from static inline function fromObjectMap<K:{ }, V>(map:ObjectMap<K,V>):Map<K,V> {
		return cast map;
	}
}

@:deprecated typedef IMap<K, V> = haxe.Constraints.IMap<K, V>;
//}
#else
//{ Haxe < 3.2
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;
import haxe.ds.WeakMap;
import haxe.ds.EnumValueMap;
@:multiType(K) abstract Map<K,V>(IMap<K,V> ) {
	public function new();
	public inline function set(key:K, value:V) this.set(key, value);
	@:arrayAccess public inline function get(key:K) return this.get(key);
	public inline function exists(key:K) return this.exists(key);
	public inline function remove(key:K) return this.remove(key);
	public inline function keys():Iterator<K> {
		return this.keys();
	}
	public inline function iterator():Iterator<V> {
		return this.iterator();
	}
	public inline function toString():String {
		return this.toString();
	}
	@:arrayAccess @:noCompletion public inline function arrayWrite(k:K, v:V):V {
		this.set(k, v);
		return v;
	}
	@:to static inline function toStringMap(t:IMap<String,V>):StringMap<V> {
		return new StringMap<V>();
	}
	@:to static inline function toIntMap(t:IMap<Int,V>):IntMap<V> {
		return new IntMap<V>();
	}
	@:to static inline function toEnumValueMapMap<K:EnumValue>(t:IMap<K,V>):EnumValueMap<K,V> {
		return new EnumValueMap<K, V>();
	}
	@:to static inline function toObjectMap<K:{ }>(t:IMap<K,V>):ObjectMap<K,V> {
		return new ObjectMap<K, V>();
	}
	@:from static inline function fromStringMap<V>(map:StringMap<V>):Map< String, V > {
		return map;
	}
	@:from static inline function fromIntMap<V>(map:IntMap<V>):Map< Int, V > {
		return map;
	}
	@:from static inline function fromObjectMap<K:{ }, V>(map:ObjectMap<K,V>):Map<K,V> {
		return map;
	}
}

interface IMap<K,V> {
	public function get(k:K):Null<V>;
	public function set(k:K, v:V):Void;
	public function exists(k:K):Bool;
	public function remove(k:K):Bool;
	public function keys():Iterator<K>;
	public function iterator():Iterator<V>;
	public function toString():String;
}

private typedef Hashable = {
	function hashCode():Int;
}
//}
#end
