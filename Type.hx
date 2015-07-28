package;

/**
 * ...
 * @author YellowAfterlife
 */
enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass( c : Class<Dynamic> );
	TEnum( e : Enum<Dynamic> );
	TUnknown;
}

@:coreApi extern class Type {
	static function getClass<T>( o : T ) : Class<T>;
	static function getEnum( o : EnumValue ) : Enum<Dynamic>;
	static function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic>;
	static function getClassName( c : Class<Dynamic> ) : String;
	static function getEnumName( e : Enum<Dynamic> ) : String;
	static function resolveClass( name : String ) : Class<Dynamic>;
	static function resolveEnum( name : String ) : Enum<Dynamic>;
	static function createInstance<T>( cl : Class<T>, args : Array<Dynamic> ) : T;
	static function createEmptyInstance<T>( cl : Class<T> ) : T;
	static function createEnum<T>( e : Enum<T>, constr : String, ?params : Array<Dynamic> ) : T;
	static function createEnumIndex<T>( e : Enum<T>, index : Int, ?params : Array<Dynamic> ) : T;
	static function getInstanceFields( c : Class<Dynamic> ) : Array<String>;
	static function getClassFields( c : Class<Dynamic> ) : Array<String>;
	static function getEnumConstructs( e : Enum<Dynamic> ) : Array<String>;
	static function typeof( v : Dynamic ) : ValueType;
	static function enumEq<T>( a : T, b : T ) : Bool;
	static function enumConstructor( e : EnumValue ) : String;
	inline static function enumParameters( e : EnumValue ) : Array<Dynamic> {
		return untyped e.slice(2);
	}

	inline static function enumIndex( e : EnumValue ) : Int {
		return untyped e[1];
	}

	static function allEnums<T>( e : Enum<T> ) : Array<T>;

}