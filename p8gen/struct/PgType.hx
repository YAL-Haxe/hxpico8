package p8gen.struct;
import p8gen.PgBuffer;
import haxe.macro.Type.BaseType;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgType extends PgBase {
	static var list:Array<PgType> = [];
	var baseType:BaseType;
	var pack:Array<String>;
	var module:String;
	function new(t:BaseType) {
		baseType = t;
		isExtern = t.isExtern || t.meta.has(":remove");
		module = t.module;
		name = t.name;
		pack = t.pack;
		path = {
			var b = new PgBuffer();
			PgPath.addPath(b, pack, name);
			b.toString();
		};
		list.push(this);
	}
	function print(r:PgBuffer) {
		
	}
}