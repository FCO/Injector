use Binder;
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
		my %bless-data;

		for $instances.keys -> \instance {
			if instance ~~ Type {
				return instance
			}
		}

		if $attrs{Type.^name}:exists {
			for @( $attrs{Type.^name} ) -> Attribute $attr {
				for $instances.keys -> \instance {
					if instance ~~ $attr.type {
						%bless-data{$attr.name.substr(2)} = instance;
						last
					}
				}
				if not %bless-data{$attr.name}:exists {
					%bless-data{$attr.name.substr(2)} = $.instanciate($attr.type);
				}
			}
		}
		my \obj = Type.bless(|%bless-data);
		$.add-instance(obj);
		obj
	}
}

multi trait_mod:<is>(Attribute $attr, :$injected!) is export {
	Injector.add-attribute($attr)
}
