enum Lifecicle <Singleton instance>;

class Bind {
	#trusts BindStorage;
	has 		$.type					;
	has Str:D	$.name			= ""		;
	has Any		$.instance is rw			;
	has Lifecicle	$.lifecicle		= Singleton	;
	has Capture	$.capture				;
}
