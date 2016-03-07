enum Lifecicle<singleton instanciation>;

class BindStorage{...}

role Binder[::Type = Mu, Callable :$instanciator] {

	has Mu:U	$.type		is rw	= Type;
	has Mu:U	$.to-type	is rw	= Type;
	has Str		$.name		is rw;
	has 		$.instance	is rw;
	has Callable	$.instanciator	is rw	= $instanciator // -> $obj {$obj.to-type.new(|$obj.pos-args, |$obj.named-args)};
	has Lifecicle	$.lifecicle	is rw	= singleton;
	has		@.pos-args	is rw;
	has		%.named-args	is rw;

	method get-obj(Binder:D:) {
		if not $!instance.defined {
			$!instance = $!instanciator(self)
		}
		my $instance = $!instance;
		if $!lifecicle !~~ singleton {
			undefine $!instance
		}
		$instance
	}

	method match(Binder:D: Mu:U :$type = Mu, Str :$name){
		$!type ~~ $type and $!name ~~ $name;
	}

	method named(Binder:D: Str:D $!name) {
		self
	}

	method life-cicle(Binder:D: Lifecicle $!lifecicle) {
		self
	}

	proto method to(Binder:D: |) {
		{*};
		BindStorage.add-obj(self);
	}

	multi method to(Binder:D: Callable $!instanciator, *@!pos-args, *%named-args) {}

	multi method to(Binder:D: Mu:U $!to-type, *@!pos-args, *%named-args) {}

	multi method to(Binder:D: Mu:D $!instance) {}
}

class BindStorage {
	my %binds{Mu:U};

	method dd {dd %binds}

	method bind(Mu:U $type) {
		Binder[$type].new;
	}

	method add-obj(Mu:D $obj) {
		%binds{$obj.type}{$obj.name.defined ?? $obj.name !! ""}.push($obj);
	}

	method get-obj(Mu:U :$type = Mu, Str :$name is copy) {
		my Mu:U @types;
		$name = "" unless $name.defined;

		for %binds.keys -> $t {
			if $type === $t {
				@types.unshift($t)
			} elsif $type ~~ $t {
				@types.push($t)
			}
		}
		if @types {
			for @types -> $t {
				if %binds{$t}{$name}:exists {
					for @(%binds{$t}{$name}) -> Binder $bind {
						my $obj = $bind.get-obj;
						return $obj if $obj ~~ $type
					}
				}
			}
		}
	}
}
