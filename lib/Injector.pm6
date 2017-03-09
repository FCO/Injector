no precompilation;
use Injector::Storage;
use Injector::Bind;
use Injector::Bind::Singleton;
use Injector::Bind::Instance;
use Injector::Bind::Clone;
use Injector::Injected::Attribute;
use Injector::Injected::Variable;

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
    $attr does Injector::Injected::Attribute;
    my $bind = %lifecycle{$lifecycle}.new: :type($attr.type), :$name, :$capture;
    $storage.add: $bind;
    $attr.prepare-inject: $bind
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
    $v does Injector::Injected::Variable;
    my $bind = %lifecycle{$lifecycle}.new: :type($v.var.WHAT), :$name, :$capture;
    $storage.add: $bind;
    $v.prepare-inject: $bind
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
