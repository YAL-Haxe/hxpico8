package p8gen.struct;
import haxe.macro.Type;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields
class PgEnum extends PgType {
	static var map:PgTypeMap<PgEnum> = new PgTypeMap<PgEnum>();
	var enumType:EnumType;
	var constructs:Array<PgEnumField> = [];
	var isSimple:Bool;
	public function new(t:EnumType) {
		super(t);
		map.wrapSet(this, this);
		enumType = t;
		for (name in t.names) {
			constructs.push(new PgEnumField(this, t.constructs.get(name)));
		}
		isSimple = true;
		for (c in constructs) {
			if (c.args.length > 0) {
				isSimple = false;
				break;
			}
		}
	}
}