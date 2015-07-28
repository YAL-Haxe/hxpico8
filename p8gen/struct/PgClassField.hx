package p8gen.struct;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgClassField extends PgField {
	var parentClass:PgClass;
	var kind:FieldKind;
	var func:TFunc = null;
	/// field' initial value
	var expr:TypedExpr;
	function new(t:PgClass, f:ClassField, isInst:Bool) {
		parentType = t;
		parentClass = t;
		name = f.name;
		type = f.type;
		kind = f.kind;
		inst = isInst;
		expr = f.expr();
		isExtern = f.meta.has(":remove");
		if (expr != null) {
			PgOpt.optExpr(expr);
			switch (expr.expr) {
			case TFunction(tfunc):
				func = tfunc;
				args = cast tfunc.args;
				type = tfunc.t;
			default:
			}
		}
		updatePath();
	}
}