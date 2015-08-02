package p8gen.expr;
import haxe.macro.Type;
import p8gen.PgBuffer;
import p8gen.PgOpt;
import p8gen.struct.PgArgument;
using p8gen.PgExpr;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgExprFunction {
	static function addOptArgs(r:PgBuffer, args:Array<PgArgument>, ?expr:TypedExpr) {
		for (arg in args) {
			var value = arg.value;
			if (value != null) {
				var arg_v = arg.v;
				if (expr != null) {
					if (PgOpt.countLocal(expr, arg_v.id) == 0) continue;
				}
				var name = arg_v.name;
				r.addString("if ");
				r.addString(name);
				r.addSepChar2("=".code, "=".code);
				r.addString("nil then ");
				r.addString(name);
				r.addSepChar("=".code);
				r.addConst(value);
				r.addString(" end");
				r.addLine();
			}
		}
	}
	static function addExprFunction(r:PgBuffer, name:String, func:TFunc, ?inst:Bool) {
		r.addString("function");
		if (name != null) {
			r.addChar(" ".code);
			r.addString(name);
		}
		r.addChar("(".code);
		var trail = false;
		if (inst) {
			r.addString("this");
			trail = true;
		}
		for (arg in func.args) {
			if (trail) r.addComma(); else trail = true;
			r.addString(arg.v.name);
		}
		r.addChar(")".code);
		var expr = func.expr;
		if (!PgExpr.isEmpty(expr)) {
			r.addLine(1);
			addOptArgs(r, func.args, expr);
			r.addExprLocal(expr);
			r.addLine( -1);
		} else r.addSep();
		r.addString("end");
	}
}