use Test;
use lib "lib";

use BindStorage;
dies-ok { BindStorage.new }, "cannot use new";
can-ok BindStorage, "instance", "should have a 'instance' method";
isa-ok BindStorage.instance, BindStorage, "'instance' should return a instance of BindStorage";

ok BindStorage.instance === BindStorage.instance;

my $b1 = BindStorage.instance.get-bind(Int);
isa-ok $b1, Bind, "get-obj should return";
my $b2 = BindStorage.instance.get-bind(Str, "name2");
isa-ok $b2, Bind, "get-obj should return";

is $b1.type, Int;
is $b1.name, "";

is $b2.type, Str;
is $b2.name, "name2";

is-deeply BindStorage.instance.binds, {"" => {Int => $b1}, name2 => {Str => $b2}};

my $b3 = BindStorage.instance.add(41);
isa-ok $b3.type, Int;
is $b3.name, "";
is $b3.instance, 41;

my $b4 = BindStorage.instance.add(42, :name<answer>);
isa-ok $b4.type, Int;
is $b4.name, "answer";
is $b4.instance, 42;

my $b5 = BindStorage.instance.add(Str);
isa-ok $b5.type, Str;
is $b5.name, "";
is $b5.instance, Any;

my $b6 = BindStorage.instance.add(Str, :name<answer>);
isa-ok $b6.type, Str;
is $b6.name, "answer";
is $b6.instance, Any;

my $r1 = BindStorage.instance.find(Int);
is $r1, $b3;

my $r2 = BindStorage.instance.find(Int, "answer");
is $r2, $b4;

my $r3 = BindStorage.instance.find(Cool);
dies-ok {$r3};

my $r4 = BindStorage.instance.find(Rat);
dies-ok {$r4};

class Foo		{has $.is-foo = True}
class Bar is Foo	{has $.is-bar = True}

my $b7 = BindStorage.instance.add(Bar.new);
isa-ok $b7.type, Bar;
is $b7.name, "";

my $r5 = BindStorage.instance.find(Foo);
is $r5, $b7;

done-testing
