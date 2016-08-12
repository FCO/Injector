use Injector;
use Test;

plan 6;

role RolePla {
}

class Ple does RolePla {
}

class Blo {
	method gist{"Blo"}
	method pi { 3.14 }
}

class Blu is Blo {
	has $.type = "Blu";
}

class Bli {
	method Str {"tested!"}
}

class Ble {
	has Int $.answer	is injected;
	has Str $.string	is injected;
	has Bli $.bli		is injected;
	has Blo $.blo		is injected;
	has RolePla $.pla	is injected;
}

class Bla {
	has Ble $.ble is injected;
}

bind(Int).to(42);
bind(Str).to("testing injector");
bind(Blo).to(Blu.new);
#bind(RolePla).to(Ple.new);

#Injector.add-instance(Ple.new);
#Injector.add-instance(42);
#Injector.add-instance("testing injector");
#Injector.add-instance(Blu.new);

#BindStorage.dd;
my $obj = Injector.inject-on: BindStorage.get-obj(:type(Bla));
$obj.perl.say;

is $obj.ble.answer,	42,			"Injected a Int";
is $obj.ble.string,	"testing injector",	"Injected a Str";
is "{$obj.ble.bli}",	"tested!",		"Injected a Custom obj";
is $obj.ble.blo.pi,	3.14,			"Injected a Custom Object inherietd";
is $obj.ble.blo.type,	"Blu",			"Using the right obj";
is $obj.ble.pla.^name,	"Ple",			"Using a Object as its role";
