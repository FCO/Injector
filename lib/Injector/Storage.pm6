no precompilation;
unit class Injector::Storage;
use Injector::Bind;
class ByType {
    has Injector::Bind    %!bind{Mu:U};
    has Injector::Storage $.parent;

    #method gist {
    #    %!bind.pairs.map({"{.key.^name} => {.value.gist}"}).join: "\n"
    #}
    method child(::?CLASS:D $parent:) {
        ::?CLASS.new: :$parent
    }
    method add(::?CLASS:D: Injector::Bind:D $bind) {
        #do if %!bind{$bind.type}:exists {
            #    die "" with %!bind{$bind.type}.obj
            #}
            %!bind{$bind.type} = $bind
        }
        method find(::?CLASS:D: Mu:U $type) {
            do if %!bind{$type}:exists {
                %!bind{$type}
            } else {
                do with %!bind.keys.first: $type -> $cache {
                    $cache
                } else {
                    do with $!parent {
                        .?find: $type
                    }
                }
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

    method find(::?CLASS:D: Mu:U $type, Str :$name = "") {
        my $bind = %!by-name{$name}.?find: $type if %!by-name{$name}:exists;
        note "Bind not found with name '$name' and type '{$type.^name}'" without $bind;
        $bind
    }

    method add-obj($obj, :$type = $obj.WHAT, :$name = "") {
        my Injector::Bind $bind = $.find($type, :$name);
        with $bind {
            .add-obj: $obj
        } else {
            die "Bind not found";
        }
    }

    method child {
        % = %!by-name.kv.map: -> $k, $v { $k => $v.child }
    }
