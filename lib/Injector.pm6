no precompilation;
use Injector::Storage;
use Injector::Bind;
use Injector::Bind::Singleton;
use Injector::Bind::Instance;
use Injector::Bind::Clone;
use Injector::Injected;

my %lifecycle = $*REPO
	.repo-chain
	.flatmap(*.loaded)
	.map({::(.Str)})
	.grep({
		.^name
		.starts-with("Injector::Bind::")
	})
	.map({.bind-type => $_})
;

my Injector::Storage $storage .= new;

multi trait_mod:<is>(Attribute:D $attr, Bool :$injected!) is export {
	trait_mod:<is>($attr, :injected{});
}
multi trait_mod:<is>(
	Attribute:D $attr,
	:%injected! (
		Str:D   :$name = "",
		Capture :$capture,
		Str:D   :$lifecycle where {%lifecycle{$_}:exists} = "singleton"
	)
) is export {
	$attr does Injector::Injected;

	my $bind = %lifecycle{$lifecycle}.new: :type($attr.type), :$name, :$capture;

	$storage.add: $bind;
	$attr.injected-bind = $bind;
}

sub note-storage is export {note $storage.gist}

multi bind(Mu $obj, *%pars) is export { bind :$obj, |%pars }
multi bind(Mu :$obj!, Mu:U :$to = $obj.WHAT, Str :$name = "", Capture :$capture) is export {
	my $bind = $storage.find($to, :$name) // Injector::Bind.new: :type($to), :$name, :$capture;
	$bind.add-obj($obj);
	$storage.add: $bind
}
