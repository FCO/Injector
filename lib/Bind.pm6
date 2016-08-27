enum Lifecicle <Singleton instance>;

class Bind {
	#trusts BindStorage;
	has 		$.type		is required			;
	has Str:D	$.name				= ""		;
	has Lifecicle	$.lifecicle			= Singleton	;
	has Capture	$.capture			= \()		;
	has Any		$!instance					;

	method get-obj {
		self!instanciate
	}

	method !instanciate {
		if $!lifecicle !~~ Singleton or not $!instance.defined {
			$!instance = $!type.bless: |$!capture
		}
		$!instance
	}
}
