use Injector;

class Ble {...}
class Bli {...}
class Bla {
	has Ble $.ble is injected;
}

class Ble {
	has Int $.answer	is injected;
	has Str $.string	is injected;
	has Bli $.bli		is injected;
}

class Bli {
	method Str {"tested!"}
}

Injector.add-instance(42);
Injector.add-instance("testing injector");

my Bla $obj = Injector.instanciate(Bla);

say "obj.ble.answer == {$obj.ble.answer}";
say "obj.ble.string == {$obj.ble.string}";
say "obj.ble.bli == {$obj.ble.bli}";
