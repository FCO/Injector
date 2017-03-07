unit class Injector::Storage;
use Injector::Bind;
class ByType {
   has Injector::Bind    %!bind{Mu:U};
   has Injector::Bind    %!cache{Mu:U};
   has Injector::Storage $.parent;

   method gist {
		%!bind.pairs.map({"{.key.^name} => {.value.gist}"}).join: "\n"
   }
   method child($parent:) {
	   ::?CLASS.new: :$parent
   }
   method add(Injector::Bind:D $bind) {
	   #do if %!bind{$bind.type}:exists {
	   #    die "" with %!bind{$bind.type}.obj
	   #}
	  %!bind{$bind.type} = $bind
   }
   method find(Mu:U $type) {
      do if %!bind{$type}:exists {
         %!bind{$type}
	  } elsif (%!cache{$type} //= %!bind.keys.first: $type).defined {
		  %!cache{$type};
	  } elsif $!parent.defined {
         $!parent.find: $type
	  }
   }
}

has ByType %!by-name{Str};

method gist {
	%!by-name.pairs.sort({.key}).map({"{.key.perl}\n{.value.gist.indent(3)}"}).join: "\n"
}

method add(Injector::Bind:D $bind) {
	(%!by-name{$bind.name} //= ByType.new).add: $bind;
}

method find(Mu:U $type, Str :$name = "") {
   %!by-name{$name}.find: $type
}

method child {
   % = %!by-name.kv.map: -> $k, $v { $k => $v.child }
}
