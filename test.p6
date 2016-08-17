#!/usr/bin/env perl6

use lib ".";
use Binder;

bind(Int, :capture(\(42)), :named<answer>);
bind(3.14);
my $bs		= BindStorage.get-instance;
my $answer	= $bs.get-obj(Int(Cool), :name<answer>);
my $pi		= $bs.get-obj(Str(Rat));
say $answer;
say $answer.WHAT;
say $pi;
say $pi.WHAT;
