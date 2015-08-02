package p8gen.struct;
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import p8gen.PgBuffer;
import p8gen.PgTypeMap;
import p8gen.expr.*;
using p8gen.PgPath;
using p8gen.PgExpr;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgClass extends PgType {
	static var map:PgTypeMap<PgClass> = new PgTypeMap<PgClass>();
	static var list:Array<PgClass> = [];
	static var current:PgClass = null;
	var classType:ClassType;
	var parent:PgClass = null;
	var children:Array<PgClass> = [];
	/// static field' list
	var statics:Array<PgClassField> = [];
	/// instance field' list
	var fields:Array<PgClassField> = [];
	/// static field' map
	var staticsMap:Map<String, PgClassField> = new Map();
	/// instance field' map
	var fieldsMap:Map<String, PgClassField> = new Map();
	/// `function new(...)` field, if any
	var constructor:PgClassField = null;
	/// `static function __init__()` expression, if any
	var initExpr:TypedExpr;
	function new(t:ClassType) {
		super(t);
		map.wrapSet(this, this);
		list.push(this);
		classType = t;
		for (f in t.statics.get()) statics.push(new PgClassField(this, f, false));
		for (f in t.fields.get()) fields.push(new PgClassField(this, f, true));
		for (f in statics) staticsMap[f.name] = f;
		for (f in fields) fieldsMap[f.name] = f;
		if (t.constructor != null) {
			constructor = new PgClassField(this, t.constructor.get(), true);
		}
		initExpr = t.init;
	}
	/// prints _create/_new functions
	function printCtr(r:PgBuffer) {
		var ctr = constructor;
		var needsNew = false;
		for (c in children) {
			if (c.constructor != null) {
				needsNew = true;
				break;
			}
		}
		var ctr_expr = ctr.func.expr;
		inline function addInit() {
			var r = {
				var b = new PgBuffer();
				b.indent = r.indent;
				b;
			};
			r.addChar("{".code);
			var len = r.length;
			r.indent++;
			var trail = false;
			inline function handleTrail() {
				if (trail) r.addChar(",".code); else trail = true;
				r.addLineSep();
			}
			// add dynamic method initializers:
			var c = this;
			var methodsPut:Map<String, Bool> = new Map();
			while (c != null) {
				for (f in c.fields) {
					var f_name = f.name;
					if (f.expr != null && methodsPut[f_name] == null) {
						switch (f.kind) {
						case FMethod(MethDynamic):
							handleTrail();
							r.addString(f_name);
							r.addSepChar("=".code);
							r.addFieldPath(c, f_name);
							methodsPut[f_name] = true;
						default:
						}
					}
				}
				c = c.parent;
			}
			// if possible, merge in variable initializations:
			if (!needsNew) {
				var list = switch (ctr_expr.expr) {
				case TBlock(list): list;
				default: [ctr_expr];
				}
				while (list.length > 0) {
					switch (list[0].expr) {
					case TBinop(OpAssign, 
					{ expr: TField({ expr: TConst(TThis) }, FInstance(_, _, cf_ref)) },
					{ expr: TConst(c) }):
						var name = cf_ref.get().name;
						if (!fieldsMap.exists(name)) break;
						handleTrail();
						r.addString(name);
						r.addSepChar("=".code);
						r.addConst(c);
						list.shift();
					default: break;
					}
				}
				ctr_expr = PgExpr.modExpr(ctr_expr, TBlock(list));
			}
			r.indent--;
			if (r.length > len) {
				r.addLineSep();
			} else r.addSep();
			r.addChar("}".code);
			return r;
		}
		var ctr_args = ctr.args;
		if (needsNew) { // _new + _create
			var new_name = {
				var b = new PgBuffer();
				b.addFieldPath(this, "new");
				b.toString();
			};
			PgExprFunction.addExprFunction(r, new_name, ctr.func, true);
			r.addLine();
			// _create:
			r.addString("function ");
			r.addFieldPath(this, "create");
			r.addChar("(".code);
			if (ctr_args.length > 0) r.addString("...");
			r.addChar(")".code);
			r.addLine(1);
			//
			r.addString("local this");
			r.addSepChar("=".code);
			r.addBuffer(addInit());
			r.addLine();
			r.addFieldPath(this, "new");
			r.addString("(...)");
			r.addLine();
			r.addString("return this");
			//
			r.addLine( -1);
			r.addString("end");
			r.addLine();
		} else { // _create
			r.addString("function ");
			r.addFieldPath(this, "create");
			r.addChar("(".code);
			var trail = false;
			for (arg in ctr_args) {
				if (trail) r.addComma(); else trail = true;
				r.addString(arg.v.name);
			}
			r.addChar(")".code);
			r.addLine(1);
			//
			var init = addInit();
			if (ctr_expr.isEmpty()) {
				r.addString("return");
				r.addSep();
				r.addBuffer(init);
			} else {
				r.addString("local this");
				r.addSepChar("=".code);
				r.addBuffer(init);
				r.addLine();
				r.addExpr(ctr_expr);
				r.addLine();
				r.addString("return this");
			}
			//
			r.addLine( -1);
			r.addString("end");
			r.addLine();
		}
	}
	override function print(r:PgBuffer) {
		if (isExtern) return;
		current = this;
		var b = new PgBuffer();
		var init = new PgBuffer();
		for (f in statics) if (!f.isExtern) {
			switch (f.kind) {
			case FVar(_, _):
				if (f.expr != null) {
					var fx:TypedExpr = {
						expr: null,
						pos: f.classField.pos,
						t: f.type,
					};
					var ct_ref = PgExpr.makeRef(classType);
					init.addExprGlobal(fx.modExpr(TBinop(OpAssign,
						fx.modExpr(TField(
							fx.modExpr(TTypeExpr(TClassDecl(ct_ref))),
							FStatic(ct_ref, PgExpr.makeRef(f.classField)))),
						f.expr)));
					init.addLine();
				}
			case FMethod(k):
				if (f.func != null) {
					PgExprFunction.addExprFunction(b, f.path, f.func);
					b.addLine();
				}
			}
		}
		if (initExpr != null) {
			init.addExpr(initExpr);
			init.addLine();
		}
		for (f in fields) if (!f.isExtern) {
			switch (f.kind) {
			case FMethod(_):
				if (f.func != null) {
					PgExprFunction.addExprFunction(b, f.path, f.func, true);
					b.addLine();
				}
			default:
			}
		}
		if (constructor != null) printCtr(b);
		if (b.length > 0) {
			#if debug
			r.addString("-- ");
			r.addString(path);
			r.addChar(":".code);
			r.addLine();
			#end
			r.addBuffer(b);
		}
		if (init.length > 0) {
			var ri = PgMain.init;
			#if debug
			ri.addString("-- ");
			ri.addString(path);
			ri.addChar(":".code);
			ri.addLine();
			#end
			ri.addBuffer(init);
		}
	}
}