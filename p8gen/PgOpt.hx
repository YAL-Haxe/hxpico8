package p8gen;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypedExprTools;
import p8gen.PgExpr.*;
/**
 * Handles mini-optimizations
 * @author YellowAfterlife
 */
@:publicFields
class PgOpt {
	static inline function iter(e:TypedExpr, f:TypedExpr->Void) {
		TypedExprTools.iter(e, f);
	}
	static function optExpr(e:TypedExpr) {
		var f:TypedExpr->Void = null;
		var z:Bool;
		//{ `v = { ...; x; }` -> `{ ...; v = x; }`
		f = function(e:TypedExpr) switch (e.expr) {
			case TBinop(OpAssign, e1, e2x ):
				iter(e, f);
				var e2 = unpackExpr(e2x);
				switch (e2.expr) {
				case TBlock(list):
					var value = list.pop();
					list.push(modExpr(e, TBinop(OpAssign, e1, value)));
					e.expr = TBlock(list);
					e.pos = e2.pos;
				default:
				}
			default: iter(e, f);
		}; f(e);
		//}
		//{ switch (enum[1]) { ... } -> { var g = enum[1]; switch (g) { ... }
		f = function(e:TypedExpr) switch (e.expr) {
			case TSwitch(e1, cases, edef):
				iter(e, f);
				switch (e1.expr) {
				case TConst(_) | TLocal(_):
				default:
					var comps = 0;
					for (c in cases) {
						comps += c.values.length;
						if (comps > 1) break;
					}
					if (comps > 1) {
						var v = makeVar("_g_switch", e1.t);
						var exprs = [modExpr(e1, TVar(v, unpackExpr(e1)))];
						if (comps == 0) {
							if (edef != null) exprs.push(edef);
						} else {
							exprs.push(modExpr(e, TSwitch(modExpr(e1, TLocal(v)), cases, edef)));
						}
						e.expr = TBlock(exprs);
					}
				}
			default: iter(e, f);
		}; f(e);
		//}
		//{ Merge single-use automatically declared variables before expressions
		f = function(e:TypedExpr) {
			iter(e, f);
			switch (e.expr) {
			case TBlock(arr):
				var check = true;
				var n = arr.length;
				var firstPass = true;
				while (check) {
					check = false;
					var k = 0;
					while (k < n) {
						switch (arr[k].expr) {
						case TVar(v, ev) if (ev != null && k < n - 1):
							do {
								// don't break some expressions:
								switch (ev.expr) {
								case TFunction(_): break;
								// (used in loops):
								case TUnop(OpIncrement, _, _): break;
								case TUnop(OpDecrement, _, _): break;
								default:
								}
								//
								var v_id = v.id;
								var next = arr[k + 1];
								// don't merge into certain expressions:
								switch (next.expr) {
								case TIf(_, _, _): break;
								case TWhile(_, _, _): break;
								case TSwitch(_, _, _): break;
								case TFunction(_): break;
								default:
								}
								// next expression must contain exactly one mention:
								var vc = countLocalExt(next, v_id);
								if (vc.writes != 0 || vc.reads != 1) break;
								var valid = true;
								// Don't merge into local function calls:
								var f = null; f = function(e:TypedExpr) {
									iter(e, f);
									switch (e.expr) {
									case TFunction(_): valid = false;
									default:
									}
								}; f(next);
								if (!valid) break;
								// consider a `local;` after use-line:
								var trail = false;
								if (firstPass && k < n - 2) {
									switch (arr[k + 2].expr) {
									case TLocal(v2) if (v2.id == v_id): trail = true;
									default:
									}
								}
								// ensure that these are the only uses around:
								var num = trail ? 2 : 1;
								if (countLocal(e, v_id) != num) break;
								//
								if (trail) { arr.splice(k + 2, 1); n--; }
								replaceLocal(next, v_id, ev);
								arr.splice(k, 1); k--; n--;
								check = true;
							} while (false);
						default:
						}
						k++;
					} // while (k < n)
					firstPass = false;
				} // while (check)
				if (arr.length == 1) e.expr = arr[0].expr;
			default:
			} // switch
		}; f(e);
		//}
		//{ Inline local variables with constant values and no modifications
		f = function(e:TypedExpr) {
			iter(e, f);
			switch (e.expr) {
			case TBlock(arr):
				var len = arr.length;
				var k = 0;
				while (k < len) {
					switch (arr[k].expr) {
					case TVar(v, e1 = { expr: TConst(_) }):
						var v_id = v.id;
						var vc = countLocalExt(e, v_id);
						if (vc.writes == 0) {
							arr.splice(k, 1); len--;
							replaceLocal(e, v_id, e1);
						} else k++;
					default: k++;
					}
				}
			default:
			}
		}; f(e);
		//}
		//{ `var i; i = v;` -> `var i = v;`
		f = function(e:TypedExpr) {
			iter(e, f);
			switch (e.expr) {
			case TBlock(arr):
				var len = arr.length;
				var k = 0;
				while (k < len) {
					switch (arr[k].expr) {
					case TVar(v, null) if (k + 1 < len):
						switch (arr[k + 1].expr) {
						case TBinop(OpAssign, { expr: TLocal(v2) }, e1) if (v2.id == v.id):
							arr[k].expr = TVar(v, e1);
							arr.splice(k + 1, 1); len--;
						default: k++;
						}
					default: k++;
					}
				}
			default:
			}
		}; f(e);
		//}
		//
	}
	static function countLocal(e:TypedExpr, localId:Int):Int {
		var r:Int = 0;
		var f:TypedExpr->Void = null;
		f = function(e:TypedExpr):Void {
			switch (e.expr) {
			case TLocal(v): if (v.id == localId) r++;
			default: iter(e, f);
			}
		}; f(e);
		return r;
	}
	static function countLocalExt(e:TypedExpr, localId:Int) {
		var reads:Int = 0;
		var writes:Int = 0;
		var isWrite:Bool = false;
		var f:TypedExpr->Void = null;
		f = function(e:TypedExpr):Void {
			switch (e.expr) {
			case TLocal(v):
				if (v.id == localId) reads++;
			case TUnop(OpIncrement, _, { expr: TLocal(v) })
				|TUnop(OpDecrement, _, { expr: TLocal(v) }):
				if (v.id == localId) {
					reads++;
					writes++;
				}
			case TBinop(OpAssign, { expr: TLocal(v) }, e1)
				|TBinop(OpAssignOp(_), { expr: TLocal(v) }, e1):
				if (v.id == localId) {
					writes++;
				}
				f(e1);
			default: iter(e, f);
			}
		}; f(e);
		return {
			reads: reads,
			writes: writes
		};
	}
	static function replaceLocal(e:TypedExpr, localId:Int, n:TypedExpr):Void {
		var f:TypedExpr->Void = null;
		f = function(e:TypedExpr):Void {
			switch (e.expr) {
			case TLocal(v):
				if (v.id == localId) {
					e.expr = n.expr;
					e.pos = n.pos;
					e.t = n.t;
				}
			default: TypedExprTools.iter(e, f);
			}
		}; f(e);
	}
}