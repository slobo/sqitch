#!/usr/bin/perl -w

use strict;
use warnings;
use 5.010;
use utf8;
use Test::More tests => 28;
#use Test::More 'no_plan';
use Test::NoWarnings;
use Test::Exception;
use App::Sqitch;
use App::Sqitch::Plan;

$ENV{SQITCH_CONFIG}        = 'nonexistent.conf';
$ENV{SQITCH_USER_CONFIG}   = 'nonexistent.user';
$ENV{SQITCH_SYSTEM_CONFIG} = 'nonexistent.sys';

BEGIN { require_ok 'App::Sqitch::Plan::LineList' or die }

my $sqitch = App::Sqitch->new;
my $plan   = App::Sqitch::Plan->new(sqitch => $sqitch);

my $foo = App::Sqitch::Plan::Change->new(plan => $plan, name => 'foo');
my $bar = App::Sqitch::Plan::Change->new(plan => $plan, name => 'bar');
my $baz = App::Sqitch::Plan::Change->new(plan => $plan, name => 'baz');
my $yo1 = App::Sqitch::Plan::Change->new(plan => $plan, name => 'yo');
my $yo2 = App::Sqitch::Plan::Change->new(plan => $plan, name => 'yo');

my $blank = App::Sqitch::Plan::Blank->new(plan => $plan);
my $alpha = App::Sqitch::Plan::Tag->new(
    plan => $plan,
    change => $yo1,
    name => 'alpha',
);

my $lines = App::Sqitch::Plan::LineList->new(
    $foo,
    $bar,
    $yo1,
    $alpha,
    $blank,
    $baz,
    $yo2,
);

is $lines->count, 7, 'Count should be six';
is_deeply [$lines->items], [$foo, $bar, $yo1, $alpha, $blank, $baz, $yo2],
    'Lines should be in order';
is $lines->item_at(0), $foo, 'Should have foo at 0';
is $lines->item_at(1), $bar, 'Should have bar at 1';
is $lines->item_at(2), $yo1, 'Should have yo1 at 2';
is $lines->item_at(3), $alpha, 'Should have @alpha at 3';
is $lines->item_at(4), $blank, 'Should have blank at 4';
is $lines->item_at(5), $baz, 'Should have baz at 5';
is $lines->item_at(6), $yo2, 'Should have yo2 at 6';

is $lines->index_of('non'), undef, 'Should not find "non"';
is $lines->index_of($foo), 0, 'Should find foo at 0';
is $lines->index_of($bar), 1, 'Should find bar at 1';
is $lines->index_of($yo1), 2, 'Should find yo1 at 2';
is $lines->index_of($alpha), 3, 'Should find @alpha at 3';
is $lines->index_of($blank), 4, 'Should find blank at 4';
is $lines->index_of($baz), 5, 'Should find baz at 5';
is $lines->index_of($yo2), 6, 'Should find yo2 at 6';

my $hi = App::Sqitch::Plan::Change->new(plan => $plan, name => 'hi');
ok $lines->append($hi), 'Append hi';
is $lines->count, 8, 'Count should now be eight';
is_deeply [$lines->items], [$foo, $bar, $yo1, $alpha, $blank, $baz, $yo2, $hi],
    'Lines should be in order with $hi at the end';

# Try inserting.
my $oy = App::Sqitch::Plan::Change->new(plan => $plan, name => 'oy');
ok $lines->insert_at($oy, 3), 'Insert a change at index 3';
is $lines->count, 9, 'Count should now be nine';
is_deeply [$lines->items], [$foo, $bar, $yo1, $oy, $alpha, $blank, $baz, $yo2, $hi],
    'Lines should be in order with $oy at index 3';
is $lines->index_of($oy), 3, 'Should find oy at 3';
is $lines->index_of($alpha), 4, 'Should find @alpha at 4';
is $lines->index_of($hi), 8, 'Should find hi at 8';

