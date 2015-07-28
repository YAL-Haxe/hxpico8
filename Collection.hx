package;

/**
 * List maps to a Lua array.
 * Indexes start at 1.
 * @author YellowAfterlife
 */
abstract Collection<T>(Array<T>) {
	public inline function new() {
		this = [];
	}
	@:from public static inline function create<T>(values:Array<T>):Collection<T> {
		return Pico.collection(values);
	}
	//
	public var size(get, never):Int;
	private inline function get_size():Int return Pico.count(this);
	//
	public inline function add(value:T):Void Pico.add(this, value);
	public inline function del(value:T):Void Pico.del(this, value);
	public inline function remove(value:T):Void Pico.del(this, value);
	public inline function iterator():Iterator<T> {
		return Pico.all(this);
	}
}
