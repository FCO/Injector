no precompilation;
use Injector::Storage;
use Injector::Bind;
use Injector::Bind::Singleton;
use Injector::Bind::Instance;
use Injector::Bind::Clone;
use Injector::Injected;

my %lifecycle = $*REPO
	.repo-chain
	.flatmap(*.loaded)
	.map({::(.Str)})
	.grep({
		.^name
		.starts-with("Injector::Bind::")
	})
	.map({.bind-type => $_})
;

my Injector::Storage $storage .= new;

multi trait_mod:<is>(Attribute:D $attr, Bool :$injected!) is export {
	trait_mod:<is>($attr, :injected{});
}
multi trait_mod:<is>(Attribute:D $attr, Str :$injected!) is export {
    trait_mod:<is>($attr, :injected{:name($injected)});
}
multi trait_mod:<is>(
	Attribute:D $attr,
	:%injected! (
		Str:D   :$name                                  = ""            ,
		Capture :$capture                               = \()           ,
		Str:D   :$lifecycle where %lifecycle.keys.any   = "singleton"
	)
) is export {
	$attr does Injector::Injected;

	my $bind = %lifecycle{$lifecycle}.new: :type($attr.type), :$name, :$capture;

	$storage.add: $bind;
	$attr.injected-bind = $bind;

    if not $attr.package.^find_method("inject-attributes") {
        $attr.package.^add_method("inject-attributes", method {
            for self.^attributes.grep: Injector::Injected -> $attr {
                #note "Inject on attribute {$attr.name} of type {$attr.type.^name}";
                $attr.set_value: self, $attr.injected-bind.get-obj without $attr.get_value: self
            }
        });
        if $attr.package.^find_method("TWEAK") -> &tweak {
            &tweak.wrap: method (|) { self.inject-attributes; nextsame }
        } else {
            $attr.package.^add_method("TWEAK", method (|) {self.inject-attributes})
        }
    }
}

multi trait_mod:<is>(Variable:D $v, Bool :$injected!) {
    trait_mod:<is>($v, :injected{})
}
multi trait_mod:<is>(Variable:D $v, Str :$injected!) {
    trait_mod:<is>($v, :injected{:name($injected)})
}
multi trait_mod:<is>(
    Variable:D $v,
	:%injected! (
		Str:D   :$name                                  = ""            ,
		Capture :$capture                               = \()           ,
		Str:D   :$lifecycle where %lifecycle.keys.any   = "singleton"
	)
) {
    my $bind = %lifecycle{$lifecycle}.new: :type($v.var.WHAT), :$name, :$capture;
    $v.block.add_phaser("ENTER", {
        #note "Inject on variable {$v.name} of type {$v.var.^name}";
        $v.var = $bind.get-obj without $v.var;
    })
}

sub note-storage is export {note $storage.gist}

multi bind(Mu $obj, *%pars) is export { bind :$obj, |%pars }
multi bind(
    Mu      :$obj!                     ,
    Mu:U    :$to       = $obj.WHAT     ,
    Str     :$name     = ""            ,
    Capture :$capture
) is export {
	die "Bind not found for name '$name' and type {$to.^name}" unless $storage.add-obj: $obj, :type($to), :$name;
}

sub bind-child is export {
    $storage .= child
}

