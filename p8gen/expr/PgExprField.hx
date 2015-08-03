package p8gen.expr;
import haxe.macro.Type;
import p8gen.PgBuffer;
import p8gen.PgMain.error;
import p8gen.struct.PgEnum;
using p8gen.PgExpr;
using p8gen.PgPath;

/**
 * ...
 * @author YellowAfterlife
 */
class PgExprField {
	public static function addExprField(r:PgBuffer, e:TypedExpr, fa:FieldAccess) {
		var ct:ClassType;
		var cf:ClassField;
		switch (fa) {
		case FInstance(ct_ref, _, cf_ref) | FClosure({ c: ct_ref }, cf_ref): {
			ct = ct_ref.get();
			cf = cf_ref.get();
			var cf_name = cf.name;
			// decide whether to use static (class_field) or dynamic (inst.field) access:
			var is_dynamic = false;
			switch (cf.kind) {
			case FVar(_, _): is_dynamic = true;
			case FMethod(MethDynamic):
				switch (e.expr) {
				case TConst(TSuper):
				default: is_dynamic = true;
				}
			default:
			}
			//
			if (is_dynamic) {
				r.addExpr(e);
				r.addChar(".".code);
				r.addString(cf_name);
			} else {
				r.addPath2(ct.pack, ct.name, cf_name);
			}
		}
		case FStatic(ct_ref, cf_ref): {
			ct = ct_ref.get();
			cf = cf_ref.get();
			r.addPath2(ct.pack, ct.name, cf.name);
		}
		case FAnon(cf_ref): {
			r.addExpr(e);
			r.addChar(".".code);
			r.addString(cf_ref.get().name);
		}
		case FDynamic(field): {
			r.addExpr(e);
			r.addChar(".".code);
			r.addString(field);
		}
		case FEnum(et_ref, ef): {
			var et = et_ref.get();
			if (PgEnum.map.baseGet(et).isSimple) {
				r.addInt(ef.index);
			} else {
				r.addChar("{".code);
				r.addSep();
				r.addInt(ef.index);
				r.addSep();
				r.addChar("}".code);
			}
		}
		default: error("This field access type is not supported.", e.pos);
		}
	}
}