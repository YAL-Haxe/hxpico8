package p8gen.struct;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgEnumField extends PgField {
	var parentEnum:PgEnum;
	var index:Int;
	function new(t:PgEnum, f:EnumField) {
		parentEnum = t;
		parentType = t;
		name = f.name;
		index = f.index;
		updatePath();
		args = [];
		switch (f.type) {
		case TFun(f_args, f_out): { // Field(...);
			type = f_out;
			for (arg in f_args) args.push({
				value: arg.opt ? TNull : null,
				v: {
					id: -1,
					name: arg.name,
					t: arg.t,
					capture: null,
					extra: null
				},
			});
		}
		default: type = f.type; // Field;
		}
	}
}