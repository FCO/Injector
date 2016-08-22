enum Lifecicle<singleton instanciation>;

role Bind[::Type]	{…}
#class BindStorage	{…}
role Injectable		{…}
role Injected		{…}

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

class BindStorage {
	my	::?CLASS	$instance	.= bless;
	has			%!by-name		;

	method new{!!!}

	method get-instance(::?CLASS:U:) {$instance}

	method add-bind(Bind $bind) {
		%!by-name{$bind.named // ""}.push: $bind
	}

	method find(::Type, Str :$name) {
		do with %!by-name{$name // ""} -> @binds {
			my @tmp;
			for @binds -> $bind {
				if $bind.type === Type {
					@tmp.unshift: $bind
				} elsif $bind.type ~~ Type {
					@tmp.push: $bind
				}
			}
			@tmp.first;
		}
	}

	method get-obj(::OrigType, Str :$name) is hidden-from-backtrace {
		my $type;
		my $cast;
		my $ret;
		if OrigType.HOW ~~ Metamodel::CoercionHOW {
			$type = OrigType.^constraint_type;
			$cast = OrigType.^target_type;
		} else {
			$cast = $type = OrigType
		}

		my Bind $bind;
		if $.find($type, :$name) -> Bind $got-bind {
			$bind = $got-bind;
		} else {
			$bind = Bind[$type].new;
			BindStorage.get-instance.add-bind: $bind
		}
		$ret = $bind.get-obj;

		unless $cast === $type {
			$ret = $ret.$cast;
			CATCH {
				die "Error converting '{$type.^name}' ({$ret}) to '{$cast.^name}'"
			}
		}
		$ret
	}

	method register-injectable(::Type) {
		
	}
}
role Injectable[::Type] {
	#trusts BindStorage;
	has 			$.injectable = True;
	has	Bind[Type]	$.bind;

	method !create-bind(Str $named?) {
		$!bind .= new: :$named;
		BindStorage.get-instance.add-bind: $!bind
	}
}

role Injected[::Type] {
	#trusts BindStorage;
	has 			$.injected = True;
	has	Bind[Type]	$!bind;
}

