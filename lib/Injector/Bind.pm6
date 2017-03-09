unit role Injector::Bind;
use Injector::Injected;

has         $.type              ;
has Str     $.name     = ""     ;
has Capture $.capture  = \()    ;
has Mu      $!obj      = $!type ;

method bind-type {…}
method get-obj   {…}

method gist {
   "{$.bind-type}: name: {$!name.perl}; type: {$!type.^name}; capture: {$!capture.perl}; obj: {$!obj.gist}; {self.WHERE}"
}

method add-obj($obj) {
	die "Trying to set obj {$obj} but bind already have a object setted" with $!obj;
	$!obj = $obj
}
method instanciate {
	$!obj.WHAT.bless: |$!capture
}
