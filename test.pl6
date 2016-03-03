use Injector;

class Ble {...}
class Bli {...}
class Blo {...}
class Blu {...}
class Bla {
	has Ble $.ble is injected;
}

class Ble {
	has Int $.answer	is injected;
	has Str $.string	is injected;
	has Bli $.bli		is injected;
	has Blo $.blo		is injected;
}

class Bli {
	method Str {"tested!"}
}

class Blo {
	method pi { 3.14 }
}

class Blu is Blo {
	has $.type = "Blu";
}

Injector.add-instance(42);
Injector.add-instance("testing injector");
Injector.add-instance(Blu.new);

my Bla $obj = Injector.instanciate(Bla);

say "obj.ble.answer == {$obj.ble.answer}";
say "obj.ble.string == {$obj.ble.string}";
say "obj.ble.bli == {$obj.ble.bli}";
say "obj.ble.blo.pi == {$obj.ble.blo.pi}";
say "obj.ble.blo.type == {$obj.ble.blo.type}";
