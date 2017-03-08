use lib "lib";
use Injector;

role Service {
	method name {…}
}

class Client {
	has Service $!service is injected;


	method greet {
		"Hello {$!service.name}"
	}
}
class MyService does Service { has $.name = "Test" }

bind MyService, :to(Service);


Client.new.greet.say
