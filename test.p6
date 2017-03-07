use lib "lib";

use Injector;

class Rand {
    has $.r = ("a" .. "z").roll(rand * 10).join;
}

class C2 {
    has Int $.a is injected
}

class C1 {
    has C2	    $.c2	is injected;
    has Int	    $.b		is injected<test>;
    has Rand    $.r	    is injected{:lifecycle<instance>};
    #has C1      $.def   is injected{:name<def>};
}

BEGIN {
    bind 42;
    bind 13, :name<test>;
    #bind C1.new(:123b), :name<def>;
}

my C1 $c is injected;
#my C1 $c-def is injected<def>;
#
say $c;
#say $c-def;

for ^3 {
        given C1.new: :123b {
        .c2.a.say;
        .b.say;
        .r.say;
    }
}



