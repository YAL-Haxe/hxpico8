package p8gen;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgBuffer extends StringBuf {
	var indent:Int = 0;
	inline function addString(s:String) add(s);
	inline function addInt(i:Int) add(i);
	inline function addBuffer(b:PgBuffer) add(b);
	inline function addChar2(c1:Int, c2:Int) {
		addChar(c1);
		addChar(c2);
	}
	/// adds a separator (space). For reading ease, not functional
	inline function addSep() {
		#if debug
		addChar(" ".code);
		#end
	}
	inline function addSepChar(c:Int) {
		addSep();
		addChar(c);
		addSep();
	}
	inline function addSepChar2(c1:Int, c2:Int) {
		addSep();
		addChar(c1);
		addChar(c2);
		addSep();
	}
	inline function addComma() {
		addChar(",".code);
		addSep();
	}
	inline function addLine(indentDelta:Int = 0) {
		indent += indentDelta;
		addChar("\n".code);
		#if debug
		var i = indent;
		while (--i >= 0) addChar("\t".code);
		#end
	}
	// same as addLine but for when it's merely a separator
	inline function addLineSep() {
		#if debug
		addLine();
		#end
	}
}