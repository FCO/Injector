
class Injector {
	my Hash $attrs = {};
	my SetHash $instances .= new;
	method add-attribute(Attribute $attr) {
		$attrs.push($attr.package.^name => $attr);
	}
	method add-instance($obj) {
		#note "add-instance: {$obj.perl}";
		$instances{$obj} = True;
	}
	method instanciate(::Type) {
		#note "instanciate: {Type.^name}";
		my %bless-data;
		#my $obj = Type.bless;

		for $instances.keys -> \instance {
			#note "{instance.^name} ~~ {Type.^name}";
			if instance ~~ Type {
				return instance
			}
		}

		#note " \$attrs{{Type.^name}}: {$attrs{Type.^name}.perl}";
		if $attrs{Type.^name}:exists {
			for @( $attrs{Type.^name} ) -> Attribute $attr {
				for $instances.keys -> \instance {
					#note "{instance.^name} ~~ {$attr.type.^name}";
					if instance ~~ $attr.type {
						#$attr.set_value: $obj, $instance;
						%bless-data{$attr.name.substr(2)} = instance;
						last
					}
				}
				#if not $attr.get_value($obj).defined {
				if not %bless-data{$attr.name}:exists {
					#$attr.set_value($obj, $.instanciate($attr.type))
					%bless-data{$attr.name.substr(2)} = $.instanciate($attr.type);
				}
			}
		}
		#say %bless-data.perl;
		#say "{Type.^name} = Type.bless(|{%bless-data})";
		my \obj = Type.bless(|%bless-data);
		#say obj.perl;
		$.add-instance(obj);
		obj
	}
}

multi trait_mod:<is>(Attribute $attr, :$injected!) is export {
	Injector.add-attribute($attr)
}
