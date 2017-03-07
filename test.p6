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

bind 42;
bind 13, :name<test>;

my C1 $c is injected;
say $c;

for ^3 {
        given C1.new: :123b {
        .c2.a.say;
        .b.say;
        .r.say;
    }
}



