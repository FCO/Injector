unit class Injector::Storage;
use Injector::Bind;
has %!bind;

sub name (Mu:U $_) {
	S/<!after ":"> ":" <+[U D _]> $ // given .^name
}

method add (Injector::Bind:D $bind) {
	%!bind{$bind.name.raku; $bind.type.&name(); $bind.bind-type} = $bind
}

method find (::?CLASS:D: Mu:U $type, Str :$name = "") {
	%!bind{$name.raku; $type.&name()}:exists ?? |%!bind{$name.raku; $type.&name()}.first.values !! Empty
}

method add-obj ($obj, :$type = $obj.WHAT, :$name = "", :$override) {
	my @binds = |$.find($type, :name($name));
	die "No bind found" unless @binds;
	for @binds {
		.add-obj($obj, :override($override))
	}
	?@binds
}
