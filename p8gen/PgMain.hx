package p8gen;
import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Position;
import haxe.macro.JSGenApi;
import p8gen.struct.*;
import sys.FileSystem;
import sys.io.File;
/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgMain {
	static var api:JSGenApi;
	static inline function error(text:String, pos:Position) {
		Context.error(text, pos);
	}
	static inline function notSupported(pos:Position) {
		error("Not supported.", pos);
	}
	static function build() {
		//
		var hasSuperClass = [];
		for (t in api.types) switch (t) {
			case TInst(ct_ref, _):
				var ct = ct_ref.get();
				var c = new PgClass(ct);
				if (ct.superClass != null) hasSuperClass.push(c);
			case TEnum(et_ref, _):
				new PgEnum(et_ref.get());
			default:
		}
		for (c in hasSuperClass) {
			c.parent = PgClass.map.baseGet(c.classType.superClass.t.get());
		}
		for (c in PgClass.list) {
			var p = c.parent;
			while (p != null) {
				p.children.push(c);
				p = p.parent;
			}
		}
		//
		var api_main = api.main;
		if (api_main != null) {
			api_main = PgExpr.unpackExpr(api_main);
			switch (api_main.expr) {
			case TCall({ expr: TField(e, FStatic(ct_ref, cf_ref))}, []):
				var cf = cf_ref.get();
				switch (cf.kind) {
				case FMethod(MethInline):
					var c = PgClass.map.baseGet(ct_ref.get());
					for (f in c.statics) if (f.name == cf.name) {
						f.isExtern = true;
						api_main = f.func.expr;
						break;
					}
				default:
				}
			default:
			}
		}
		//
		var r = new PgBuffer();
		/*#if debug
		r.addString("-- ");
		r.addString(Date.now().toString());
		r.addLine();
		#end*/
		for (t in PgType.list) t.print(r);
		if (api_main != null) {
			PgExpr.addExpr(r, api_main);
			r.addLine();
		}
		// and save it:
		var path = api.outputFile;
		var rstr = r.toString();
		inline function outerror(text:String) {
			error(text, Context.makePosition({ file: path, min: 0, max: 0 }));
		}
		switch (Path.extension(path.toLowerCase())) {
		case "p8hx": {
			path = path.substring(0, path.length - 2);
			if (!FileSystem.exists(path)) outerror("Can't modify file as it is missing.");
			var code = File.getContent(path);
			//
			var mark_before = "__lua__";
			var pos = code.indexOf(mark_before);
			if (pos < 0) outerror('The file is missing "code start" mark ($mark_before)');
			var code_before = code.substring(0, pos + mark_before.length);
			//
			var mark_after = "__gfx__";
			pos = code.lastIndexOf(mark_after);
			if (pos < 0) outerror('The file is missing "code end" mark ($mark_after)');
			var code_after = code.substring(pos);
			//
			var code_out = {
				var b = new PgBuffer();
				b.addString(code_before);
				b.addChar("\n".code);
				b.addString(rstr);
				if (rstr.charCodeAt(rstr.length - 1) != "\n".code) b.addChar("\n".code);
				b.addString(code_after);
				b.toString();
			};
			File.saveContent(path, code_out);
		}
		case "lua": File.saveContent(path, rstr);
		default: outerror("Output file should be .lua (for saving code alone) or .p8hx (for patching code in a .p8 file of same path)");
		}
	}
	static function use() {
		Compiler.setCustomJSGenerator(function(_api) {
			api = _api;
			build();
		});
	}
}