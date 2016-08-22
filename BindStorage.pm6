say "BindStorabe";
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
