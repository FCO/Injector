unit role Injector::Bind;
use Injector::Injected;

has         $.type              ;
has Str     $.name     = ""     ;
has Capture $.capture  = \()    ;
has Mu      $!obj      = $!type ;

method bind-type(::?CLASS:U:) {…}
method get-obj                {…}

method gist {
   "{$.bind-type}: name: {$!name.perl}; type: {$!type.^name}; capture: {$!capture.perl}; obj: {$!obj.gist}; {self.WHERE}"
}

method add-obj($!obj) {}
method instanciate {
	$!obj.WHAT.bless: |$!capture
}