use Injector::Bind;
unit class Injector::Bind::Singleton does Injector::Bind;

method bind-type(::?CLASS:_:) {"singleton"}
method get-obj                {$!obj //= $.instanciate}
