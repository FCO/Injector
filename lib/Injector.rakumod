no precompilation;
use Injector::Storage;
use Injector::Bind;
use Injector::Bind::Singleton;
use Injector::Bind::Instance;
use Injector::Bind::Clone;
use Injector::Bind::ObjectType;
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

sub undefined(Mu:U $type) { so / <!after ':'> ':U' $/ given $type.^name }

sub create-bind(
    $var,
    Str:D   :$name      = ""   ,
    Mu:U    :$type             ,
    Capture :$capture   = \()  ,
    Str     :$lifecycle is copy,
) {
    if $lifecycle and not %lifecycle{$lifecycle}:exists {
        die "Unknow lifecycle '{$lifecycle}'"
    }
    $lifecycle //= undefined($type) ?? "object-type" !! "singleton";
    my Injector::Bind $bind = %lifecycle{$lifecycle}.new: :$type, :$name, :$capture;
    $storage.add: $bind;
    $var.prepare-inject: $bind
}

multi trait_mod:<is>(Attribute:D $attr, Bool :$injected!) is export {
    trait_mod:<is>($attr, :injected{});
}
multi trait_mod:<is>(Attribute:D $attr, Str :$injected!) is export {
    trait_mod:<is>($attr, :injected{:name($injected)});
}
multi trait_mod:<is>(
    Attribute:D $attr,
    :%injected! (
        Str:D   :$name       = ""  ,
        Capture :$capture    = \() ,
        Str     :$lifecycle        ,
    )
) is export {
    $attr does Injector::Injected::Attribute;
    create-bind $attr, :type($attr.type), |%injected
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
        Str:D   :$name      = "" ,
        Capture :$capture   = \(),
        Str     :$lifecycle      ,
    )
) {
    $v does Injector::Injected::Variable;
    create-bind $v, :type($v.var.WHAT), |%injected
}

sub note-storage is export {note $storage.gist}

multi bind(Mu $obj, *%pars) is export { bind :$obj, |%pars }
multi bind(
    Mu      :$obj!                ,
    Mu:U    :$to       = $obj.WHAT,
    Str     :$name     = ""       ,
    Capture :$capture             ,
    Bool    :$override            ,
) is export {
    die "Bind not found for name '$name' and type {$to.^name}"
        unless $storage.add-obj: $obj, :type($to), :$name, :$override;
}

=begin pod

=head1 Injector

A perl6 dependency injector

=head2 Synopsys

=begin code :lang<raku>
use lib "lib";

use Injector;

class Rand {
    has $.r = ("a" .. "z").roll(rand * 10).join;
}

class C2 {
    has Int $.a is injected
}

class C1 {
    has C2      $.c2    is injected;
    has Int     $.b     is injected<test>;
    has Rand    $.r     is injected{:lifecycle<instance>};
}

BEGIN {
    bind 42;
    bind 13, :name<test>;
}

my C1 $c is injected;
say $c;                     # C1.new(c2 => C2.new(a => 42), b => 13, r => Rand.new(r => "qo"))

for ^3 {
    given C1.new: :123b {
        .c2.a.say;          # 42                            42                          42
        .b.say;             # 123                           123                         123
        .r.say;             # Rand.new(r => "ztjbpvqka")    Rand.new(r => "zsmqnrr")    Rand.new(r => "wmsq")
    }
}

=end code

=end pod
