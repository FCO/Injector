
class Injector {
	my Hash $attrs = {};
	my SetHash $instances .= new;
	method add-attribute(Attribute $attr) {
		$attrs.push($attr.package.^name => $attr);
	}
	method add-instance($obj) {
		$instances{$obj} = True;
	}
	method instanciate(::Type) {
		my $obj = Type.bless;
		if $attrs{Type.^name}:exists {
			for @( $attrs{Type.^name} ) -> Attribute $attr {
				for $instances.keys -> $instance {
					if $instance ~~ $attr.type {
						$attr.set_value: $obj, $instance;
						last
					}
				}
				if not $attr.get_value($obj).defined {
					$attr.set_value($obj, $.instanciate($attr.type))
				}
			}
		}
		add-instance: $obj;
		$obj
	}
}

multi trait_mod:<is>(Attribute $attr, :$injected!) is export {
	Injector.add-attribute($attr)
}
