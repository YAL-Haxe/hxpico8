package p8gen.struct;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgField extends PgBase {
	var parentType:PgType;
	var type:Type;
	/// whether it's an instance field (instance methods take 'this' arg)
	var inst:Bool = false;
	var args:Array<PgArgument> = null;
	inline function updatePath() {
		path = {
			var s = parentType.path;
			if (s != "") s += "_";
			s += name;
			s;
		};
	}
}