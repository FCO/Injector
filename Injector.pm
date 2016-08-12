use Binder;

class Injector{...}

my $instanciator = -> $obj {
	Injector.inject-on($obj.get-obj)
};

sub bind(Mu:U $type) is export {
	#Binder[$type].new
	Binder[$type, :$instanciator].new
}

class Injector {
	my Hash $attrs = {};
	my SetHash $instances .= new;

	method add-attribute(Attribute $attr) {
		$attrs.push($attr.package.^name => $attr);
	}
	method inject-on($obj) {
		note "inject-on";
		my $type = $obj.WHAT;
		my %bless-data;

		if BindStorage.exists($type) {
			for @( $attrs{$type.^name} ) -> Attribute $attr {
				for $instances.keys -> \instance {
					if instance ~~ $attr.type {
						$?CLASS.set_value($obj, instance);
						last
					}
				}
				if not %bless-data{$attr.name}:exists {
					my $type = $attr.type;
					$?CLASS.set_value($obj, BindStorage.get-obj(:$type));
				}
			}
		}
		#$.add-instance($obj);
		$obj
	}
}

multi trait_mod:<is>(Attribute $attr, :$injected!) is export {
	Injector.add-attribute($attr)
}
