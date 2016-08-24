use Test;
use lib "lib";

use Injector;

class Bla {
	has $.bla is injected;
}

does-ok	Bla.^attributes[0], Injected,		"is injected should do the injected role";
isa-ok	Bla.^attributes[0].injected, Bind,	"is injected should insert a bind obj on the parameter";

class Ble {
	has $.bla is injected;
	has $.ble;
}

does-ok	Ble.^attributes[0], Injected,		"is injected should do the injected role";
isa-ok	Ble.^attributes[0].injected,	Bind,	"is injected should insert a bind obj on the parameter";
nok	Ble.^attributes[1] ~~ Injected,		"if parameter isnt injected it shouldnt do the role";

class Bli {
	has $.bla is injected<name>;
}

does-ok	Bli.^attributes[0],			Injected,	"is injected should do the injected role";
isa-ok	Bli.^attributes[0].injected,		Bind,		"is injected should insert a bind obj on the parameter";
is	Bli.^attributes[0].injected.name,	"name",		"the bind obj should have a name";

done-testing;
