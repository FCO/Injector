enum Lifecicle<singleton instanciation>;

role Bind[::Type = Any] {
	has Any:U	$.type		= Type		;
	has Str		$.named				;
	has Lifecicle	$.lifecicle	= singleton	;
	has 		$.instance			;
	has Capture	$.capture			;
	has Bool	$.done		= False		;

	method get-obj {
		do given $!lifecicle {
			when singleton {
				$!instance = self!instanciate without $!instance;
				$!instance
			}
			default {
				self!instanciate
			}
		}
	}

	method !injectable-attrs {
		#Type.^attributes.grep: {$_.type ~~ Injected};
	}

	method !instanciate {
		my Attribute @attr = self!injectable-attrs;
		do with $!capture -> $cap {
			Type.bless(|@attr, |$cap)
		} else {
			Type.bless(|@attr)
		}
	}
}

