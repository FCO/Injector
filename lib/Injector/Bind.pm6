unit role Injector::Bind;
use Injector::Injected;

has         $.type;
has Str     $.name     = "";
has Capture $.capture  = \();
has Mu      $!obj;

method bind-type(::?CLASS:U:) {…}
method get-obj                {…}

method gist {
   "{$.bind-type}: name: {$!name.perl}; type: {$!type.^name}; capture: {$!capture.perl}; obj: {$!obj.gist}"
}

method add-obj($!obj) {}
method !get-params {
   |do for $!type.^attributes.grep: Injector::Injected -> Attribute:D $attr {
	   $attr.name.substr(2) => $attr.injected-bind.get-obj
   }
}

method instanciate {
	$!obj.WHAT.bless: |self!get-params, |$!capture
}
