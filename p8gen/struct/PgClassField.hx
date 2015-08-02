package p8gen.struct;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgClassField extends PgField {
	/// class containing this field
	var parentClass:PgClass;
	var classField:ClassField;
	var kind:FieldKind;
	/// function' instance (if field is a function)
	var func:TFunc = null;
	/// field' initial value
	var expr:TypedExpr;
	function new(t:PgClass, f:ClassField, isInst:Bool) {
		parentType = t;
		parentClass = t;
		classField = f;
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