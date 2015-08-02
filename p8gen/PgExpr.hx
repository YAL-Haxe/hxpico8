package p8gen;
import haxe.macro.Type;
import p8gen.expr.*;
import p8gen.PgMain.error;
import p8gen.PgMain.notSupported;
import p8gen.struct.*;
using p8gen.PgExpr;
using p8gen.PgPath;
/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgExpr {
	/// whether currently printing into the global scope (not inside any function)
	static var globalScope:Bool = false;
	static function addConst(r:PgBuffer, c:TConstant) {
		switch (c) {
		case TInt(i): r.addInt(i);
		case TFloat(f): {
			var len = f.length;
			if (f.charCodeAt(len - 1) == ".".code) {
				r.addSub(f, 0, len - 1);
			} else r.add(f);
		}
		case TString(s): {
			var dq:Bool = (s.indexOf('"') < 0) || (s.indexOf("'") >= 0);
			r.addChar(dq ? '"'.code : "'".code);
			for (i in 0 ... s.length) {
				var c:Int = StringTools.fastCodeAt(s, i);
				switch (c) {
				case '"'.code:
					if (dq) r.addChar("\\".code);
					r.addChar(c);
				case "\r".code: r.addChar2("\\".code, "r".code);
				case "\n".code: r.addChar2("\\".code, "n".code);
				default: r.addChar(c);
				}
			}
			r.addChar(dq ? '"'.code : "'".code);
		}
		case TBool(b): r.addString(b ? "true" : "false");
		case TThis: r.addString("this");
		case TNull: r.addString("nil");
		case TSuper: r.addString("super");
		default:
		}
	}
	static function addExpr(r:PgBuffer, e:TypedExpr) {
		//{
		function intForCond(v_id:Int, nodes:Array<TypedExpr>):Bool {
			if (nodes.length < 1) return false;
			switch (nodes[0].expr) {
			case TVar(_, { expr: TUnop(OpIncrement, true, { expr: TLocal({ id: v_idx }) }) }):
				if (v_idx != v_id) return false;
			default: return false;
			}
			return true;
		}
		function intForGen(min:TypedExpr, max:TypedExpr, block:TypedExpr):Void {
			r.addString("for ");
			var nodes = switch (block.expr) {
			case TBlock(el): el;
			default: null;
			}
			switch (nodes[0].expr) {
			case TVar(v, _): r.addString(v.name);
			default:
			}
			r.addSepChar("=".code);
			r.addExpr(min);
			r.addComma();
			r.addExpr(offsetInt(max, -1));
			r.addString(" do");
			r.addLine(1);
			r.addExpr(modExpr(block, TBlock(nodes.slice(1))));
			r.addLine( -1);
			r.addString("end");
		}
		function iterForGen(v:TVar, eiter:TypedExpr, eblock:TypedExpr) {
			r.addString("for ");
			r.addString(v.name);
			r.addString(" in ");
			r.addExpr(eiter);
			r.addString(" do");
			r.addLine(1);
			r.addExpr(eblock);
			r.addLine( -1);
			r.addString("end");
		}
		//}
		switch (e.expr) {
		case TConst(c): addConst(r, c);
		case TLocal(v): r.addString(v.name);
		case TArray(arr, idx): {
			switch (arr.t) {
			case TEnum(et_ref, _) if (PgEnum.map.baseGet(et_ref.get()).isSimple):
				r.addExpr(arr);
			default:
				r.addExpr(arr);
				r.addChar("[".code);
				r.addExpr(idx);
				r.addChar("]".code);
			}
		}
		case TBinop(OpAssign, { expr: TField(e1, FStatic(ctr, cfr)) }, { expr: TFunction(f) }): {
			var c = PgClass.map.baseGet(ctr.get());
			var cf = c.staticsMap.get(cfr.get().name);
			PgExprFunction.addExprFunction(r, cf.path, f);
		}
		case TBinop(OpAssignOp(op), e1, e2): {
			r.addExpr(e1);
			switch (op) {
			case OpAdd: r.addSepChar2("+".code, "=".code);
			case OpMult: r.addSepChar2("*".code, "=".code);
			case OpDiv: r.addSepChar2("/".code, "=".code);
			case OpSub: r.addSepChar2("-".code, "=".code);
			case OpMod: r.addSepChar2("%".code, "=".code);
			default: notSupported(e.pos);
			}
			r.addExpr(e2);
		}
		case TBinop(op = OpAnd | OpOr | OpXor | OpShl | OpShr, e1, e2): {
			switch (op) {
			case OpAnd: r.addString("band");
			case OpOr: r.addString("bor");
			case OpXor: r.addString("bxor");
			case OpShl: r.addString("shl");
			case OpShr: r.addString("shr");
			default:
			}
			r.addChar("(".code);
			r.addExpr(e1);
			r.addComma();
			r.addExpr(e2);
			r.addChar(")".code);
		}
		case TBinop(OpAdd, e1, e2): {
			var _e1_isString = switch (e1.t) {
			case TInst(ct_ref, _) if (ct_ref.get().name == "String"): true;
			default: false;
			}
			var _e2_isString = switch (e2.t) {
			case TInst(ct_ref, _) if (ct_ref.get().name == "String"): true;
			default: false;
			}
			r.addExpr(e1);
			if (_e1_isString || _e2_isString) {
				r.addSepChar2(".".code, ".".code);
			} else {
				r.addSepChar("+".code);
			}
			r.addExpr(e2);
		}
		case TBinop(op, e1, e2): {
			r.addExpr(e1);
			switch (op) {
			case OpAdd: r.addSepChar("+".code);
			case OpMult: r.addSepChar("*".code);
			case OpDiv: r.addSepChar("/".code);
			case OpSub: r.addSepChar("-".code);
			case OpAssign: r.addSepChar("=".code);
			case OpEq: r.addSepChar2("=".code, "=".code);
			case OpNotEq: r.addSepChar2("!".code, "=".code);
			case OpGt: r.addSepChar(">".code);
			case OpGte: r.addSepChar2(">".code, "=".code);
			case OpLt: r.addSepChar("<".code);
			case OpLte: r.addSepChar2("<".code, "=".code);
			case OpBoolAnd: r.addString(" and ");
			case OpBoolOr: r.addString(" or ");
			case OpMod: r.addSepChar("%".code);
			default: notSupported(e.pos);
			}
			r.addExpr(e2);
		}
		case TField(e1, fa): PgExprField.addExprField(r, e1, fa);
		// TTypeExpr
		case TParenthesis(e1): {
			r.addChar("(".code);
			r.addExpr(e1);
			r.addChar(")".code);
		}
		case TObjectDecl(fields): {
			r.addChar("{".code);
			if (fields.length > 0) {
				r.addLine(1);
				var trail = false;
				for (f in fields) {
					if (trail) {
						r.addChar(",".code);
						r.addLineSep();
					} else trail = true;
					r.addString(f.name);
					r.addSepChar("=".code);
					r.addExpr(f.expr);
				}
				r.addLine( -1);
			} else r.addSep();
			r.addChar("}".code);
		}
		case TArrayDecl(args): {
			r.addChar("{".code);
			if (args.length > 0) {
				r.addSep();
				r.addChar("[".code);
				r.addInt(0);
				r.addChar("]".code);
				r.addSepChar("=".code);
				var trail = false;
				for (arg in args) {
					if (trail) r.addComma(); else trail = true;
					r.addExpr(arg);
				}
				r.addSep();
			} else r.addSep();
			r.addChar("}".code);
		}
		case TCall(e1, args): PgExprCall.addExprCall(r, e1, args);
		case TNew(ct_ref, _, args): {
			r.addFieldPath(PgClass.map.baseGet(ct_ref.get()), "create");
			r.addChar("(".code);
			PgExprCall.addArgs(r, args);
			r.addChar(")".code);
		}
		case TUnop(OpNeg, false, e1): r.addChar("-".code); r.addExpr(e1);
		case TUnop(OpNot, false, e1): r.addString("not "); r.addExpr(e1);
		case TUnop(OpNegBits, false, e1): r.addString("bnot("); r.addExpr(e1); r.addChar(")".code);
		case TFunction(f): PgExprFunction.addExprFunction(r, null, f);
		case TVar(v, e1): {
			if (!globalScope) r.addString("local ");
			r.addString(v.name);
			if (e1 != null) {
				r.addSepChar("=".code);
				r.addExpr(e1);
			}
		}
		case TBlock([ //{ for (i in a ... b) -> for i = a, b - 1
			{ expr: TVar({ id: v_id }, min) },
			{ expr: TWhile(
				{ expr: TParenthesis({ expr: TBinop(OpLt, { expr: TLocal({ id: v_id2 }) }, max) }) },
				block = { expr: TBlock(nodes) },
				true
			) }
		]) if (v_id == v_id2 && intForCond(v_id, nodes)): {
			intForGen(min, max, block);
		} //}
		case TBlock([ //{ for (i in a ... b) -> for i = a, b - 1
			{ expr: TVar({ id: v_id }, min) },
			{ expr: TVar({ id: q_id }, max) },
			{ expr: TWhile(
				{ expr: TParenthesis({ expr: TBinop(OpLt,
					{ expr: TLocal({ id: v_id2 }) },
					{ expr: TLocal({ id: q_id2 }) }
				) }) },
				block = { expr: TBlock(nodes) },
				true
			) }
		]) if (v_id == v_id2 && q_id == q_id2 && intForCond(v_id, nodes)): {
			intForGen(min, max, block);
		} //}
		case TBlock(list): {
			var trail = false;
			for (ei in list) {
				switch (ei.expr) {
				case TConst(_) | TLocal(_):
				case TBlock(_) if (isEmpty(ei)):
				default:
					if (trail) {
						r.addLine();
					} else trail = true;
					r.addExpr(ei);
				}
			}
		}
		case TFor(v, eiter, eblock): {
			switch (eiter.expr) {
			case TCall(ecall, args):
				var call = {
					var b = new PgBuffer();
					b.addExpr(ecall);
					b.toString();
				};
				switch (call) {
				case "loop": {
					r.addString("for ");
					r.addString(v.name);
					r.addSepChar("=".code);
					r.addExpr(args[0]);
					r.addComma();
					r.addExpr(args[1]);
					if (args.length > 2) {
						r.addComma();
						r.addExpr(args[2]);
					}
					r.addString(" do");
					r.addLine(1);
					r.addExpr(eblock);
					r.addLine( -1);
					r.addString("end");
				}
				default: iterForGen(v, eiter, eblock);
				}
			default: iterForGen(v, eiter, eblock);
			}
		}
		case TIf(econd, ethen, eelse): {
			r.addString("if ");
			r.addExpr(unpackExpr(econd));
			r.addString(" then");
			r.addLine(1);
			r.addExpr(ethen);
			r.addLine( -1);
			if (eelse != null) {
				r.addString("else");
				eelse = unpackExpr(eelse);
				switch (eelse.expr) {
				case TIf(_, _, _): r.addExpr(eelse);
				default:
					r.addLine(1);
					r.addExpr(eelse);
					r.addLine( -1);
					r.addString("end");
				}
			} else r.addString("end");
		}
		case TWhile(econd, eiter, true): { // while (cond) iter;
			r.addString("while ");
			r.addExpr(unpackExpr(econd));
			r.addString(" do");
			r.addLine(1);
			r.addExpr(eiter);
			r.addLine( -1);
			r.addString("end");
		}
		case TWhile(econd, eiter, false): { // do iter while (cond);
			r.addString("repeat");
			r.addLine(1);
			r.addExpr(eiter);
			r.addLine( -1);
			r.add("until ");
			r.addExpr(invertExpr(econd));
		}
		case TSwitch(e1, ecases, edef): {
			e1 = unpackExpr(e1);
			var es = {
				var b = new PgBuffer();
				b.addExpr(e1);
				b.toString();
			};
			var trail = false;
			for (ecase in ecases) {
				if (trail) r.addString("else"); else trail = true;
				r.addString("if ");
				var trail2 = false;
				for (evalue in ecase.values) {
					if (trail2) r.addString(" or "); else trail2 = true;
					r.addString(es);
					r.addSepChar2("=".code, "=".code);
					r.addExpr(evalue);
				}
				r.addString(" then");
				r.addLine(1);
				r.addExpr(ecase.expr);
				r.addLine(-1);
			}
			if (edef != null) {
				r.addString("else");
				r.addLine(1);
				r.addExpr(edef);
				r.addLine(-1);
			}
			if (trail) r.addString("end");
		}
		// TTry
		case TReturn(e1): {
			r.addString("return");
			if (e1 != null) {
				r.addChar(" ".code);
				r.addExpr(e1);
			}
		}
		case TBreak: r.addString("break");
		case TContinue: r.addString("continue");
		// TThrow
		case TCast(e1, _): r.addExpr(e1);
		case TMeta(_, e1): r.addExpr(e1);
		case TEnumParameter(e1, ef, i): {
			r.addExpr(e1);
			r.addChar("[".code);
			r.addInt(i + 2);
			r.addChar("]".code);
		}
		default: {
			//notSupported(e.pos);
			r.addString("--[[" + e.expr.getName() + "]]");
		}
		}
	}
	static inline function addExprGlobal(r:PgBuffer, e:TypedExpr):Void {
		var _gs = globalScope;
		globalScope = true;
		r.addExpr(e);
		globalScope = _gs;
	}
	static inline function modExpr(src:TypedExpr, expr:TypedExprDef):TypedExpr {
		return { expr: expr, pos: src.pos, t: src.t };
	}
	static inline function makeVar(name:String, ?type:Type, ?id:Int):TVar {
		return { name: name, id: id, t: type, capture: false, extra: null };
	}
	static inline function makeRef<T>(v:T):Ref<T> {
		return {
			get: function():T return v,
			toString: function():String return Std.string(v)
		};
	};
	static function offsetInt(e:TypedExpr, d:Int):TypedExpr {
		e = unpackExpr(e);
		var rx:TypedExprDef;
		switch (e.expr) {
		case TConst(TInt(i)): rx = TConst(TInt(i + d));
		case TBinop(OpAdd, e1, e2 = { expr: TConst(TInt(i)) }):
			rx = TBinop(OpAdd, e1, modExpr(e2, TConst(TInt(i + d))));
		default:
			if (d > 0) {
				rx = TBinop(OpAdd, e, modExpr(e, TConst(TInt(d))));
			} else {
				rx = TBinop(OpSub, e, modExpr(e, TConst(TInt(-d))));
			}
		}
		return modExpr(e, rx);
	}
	/// inverts a condition-expression
	static function invertExpr(e:TypedExpr):TypedExpr {
		e = unpackExpr(e);
		var rx:TypedExprDef;
		switch (e.expr) {
		case TUnop(OpNot, _, e1): rx = e1.expr;
		default: rx = TUnop(OpNot, false, e);
		}
		return modExpr(e, rx);
	}
	static function unpackExpr(e:TypedExpr):TypedExpr {
		while (e != null) switch (e.expr) {
		case TParenthesis(e1): e = e1;
		case TCast(e1, _): e = e1;
		case TBlock([e1]): e = e1;
		case TMeta(_, e1): e = e1;
		default: break;
		}
		return e;
	}
	static function isEmpty(e:TypedExpr) {
		switch (e.expr) {
		case TBlock(m):
			if (m.length == 0) {
				return true;
			} else if (m.length == 1) {
				return isEmpty(m[0]);
			}
		default:
		}
		return false;
	}
}