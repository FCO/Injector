use Injector::Bind;
unit class Injector::Bind::Clone does Injector::Bind;

method bind-type(::?CLASS:U:) {"clone"}
method get-obj                {$!obj .= clone}
