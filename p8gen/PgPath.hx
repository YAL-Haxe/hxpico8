package p8gen;
import p8gen.struct.PgType;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgPath {
	static inline function addPath(r:PgBuffer, pkg:Array<String>, name:String) {
		for (p in pkg) {
			r.addString(p);
			r.addChar("_".code);
		}
		r.addString(name);
	}
	static inline function addPath2(r:PgBuffer, pkg:Array<String>, name:String, field:String) {
		var l = r.length;
		addPath(r, pkg, name);
		if (r.length > l) r.addChar("_".code);
		r.addString(field);
	}
	static inline function addFieldPath(r:PgBuffer, type:PgType, field:String) {
		addPath2(r, type.pack, type.name, field);
	}
}