enum Lifecicle<singleton instanciation>;

role Bind[::Type = Any] is export {
	has Any:U	$.type		= Type		;
	has Str		$.named				;
	has Lifecicle	$.lifecicle	= singleton	;
	has 		$.instance			;
	has Capture	$.capture	= \()		;
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

	method !instanciate {
		do with $!capture -> $cap {
			Type.new(|$cap)
		} else {
			Type.new
		}
	}
}

class BindStorage {
	my	::?CLASS	$instance		.= bless;
	has			%!by-name			;

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
		if $.find($type, :$name) -> Bind $bind {
			$ret = $bind.get-obj
		}
		unless $cast === $type {
			$ret = $ret.$cast;
			CATCH {
				die "Error converting '{$type.^name}' ({$ret}) to '{$cast.^name}'"
			}
		}
		$ret
	}
}

multi bind(Any:D $instance, Str :$named, Lifecicle :$lifecicle!) is export {
	BindStorage.get-instance.add-bind: Bind[$instance.WHAT].new :$instance:$named:$lifecicle
}

multi bind(Any:U $type, Capture :$capture, Str :$named, Lifecicle :$lifecicle!) is export {
	BindStorage.get-instance.add-bind: Bind[$type].new :$capture:$named:$lifecicle
}

multi bind(Any:D $instance, Str :$named) is export {
	BindStorage.get-instance.add-bind: Bind[$instance.WHAT].new :$instance:$named
}

multi bind(Any:U $type, Capture :$capture, Str :$named) is export {
	BindStorage.get-instance.add-bind: Bind[$type].new :$capture:$named
}
