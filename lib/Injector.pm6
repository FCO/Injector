use Injected;
use Bind;

multi trait_mod:<is>(Attribute $par, :$injected!) is export {
	$par does Injected[$injected ~~ Str ?? $injected !! ""];
}
