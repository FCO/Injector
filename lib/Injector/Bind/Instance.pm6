use Injector::Bind;
unit class Injector::Bind::Instance does Injector::Bind;

method bind-type(::?CLASS:U:) {"instance"}
method get-obj                {$.instanciate}
