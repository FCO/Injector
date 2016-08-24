use Bind;
class BindStorage {
	my	::?CLASS	$instance	.= bless;
	has			%.binds;

	method new { !!! }
	method instance(::?CLASS:U: --> ::?CLASS:D){ $instance }

	method get-bind(::?CLASS:D: ::Type, Str:D $name = "" --> Bind) {
		without %!binds{$name}{Type.^name} -> $bind is rw {
			$bind = Bind.new(:type(Type), :name($name));
		}

		%!binds{$name}{Type.^name}
	}

	method find(::?CLASS:D: ::Type, Str $name = "") {
		do with %!binds{$name}{Type.^name} -> Bind:D $bind {
			$bind
		} else {
			my @poss = %!binds{$name}.values.grep(*.type ~~ Type);
			do if @poss.elems == 0 {
				fail "No bind found for type {Type.^name} and name $name";
			} elsif @poss.elems > 1 {
				fail "More than one bind found for type {Type.^name} and name $name";
			}
			@poss.first
		}
	}

	multi method add(::?CLASS:D: Any:D $instance, Str :$name, *%pars --> Bind) {
		my Bind $b	= callwith($instance.WHAT, :$name, |%pars);
		$b.instance	= $instance;
		$b
	}

	multi method add(::?CLASS:D: ::Type, Str :$name, Capture :$capture? --> Bind) {
		my Bind $bind = do with $name {
			self.get-bind(Type, $name);
		} else {
			self.get-bind(Type);
		}
		$bind.capture = $capture with $capture;
		$bind
	}
}
