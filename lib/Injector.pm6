use Injected;
use Bind;

#| Trait "is injected" to be used on class attributes
#| Example:
#|     class ServiceClient {
#|         has HTTP::Client $!ua is injected;
#|         ...
#|     }
multi trait_mod:<is>(Attribute $par, :$injected!) is export {
	$par does Injected[$injected ~~ Str ?? $injected !! ""];
}
