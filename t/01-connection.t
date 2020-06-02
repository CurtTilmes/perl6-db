#!/usr/bin/env raku
use Test;
use DB::Mock;

plan 17;

isa-ok my $m = DB::Mock.new, DB::Mock, 'Create object';

is $mock-connections, 0, 'No connections yet';

isa-ok my $db = $m.db, DB::Mock::Connection, 'Create a connection';

is $mock-connections, 1, '1 Connection created';

lives-ok { $db.finish }, 'Finish the connection';

is $mock-connections, 1, '1 Connection still cached';

is $m.connections.elems, 1, 'Cache has 1 connection';

isa-ok $db = $m.db, DB::Mock::Connection,
    'Get connection, should come from cache';

is $mock-connections, 1, '1 Connection still cached';

is $m.connections.elems, 0, 'Cache has no connections';

$db.state = False; # Kill the connection

lives-ok { $db.finish }, 'Finish dead connection';

is $mock-connections, 0, 'Freed the bad connection';

is $m.connections.elems, 0, 'Cache has no connections';

my @conns = do $m.db for ^3;  # Create three connections;

.finish for @conns;           # Finish them

is $mock-connections, 3, '3 connections still active';

is $m.connections.elems, 3, 'All of them in the cache';

lives-ok { $m.finish }, 'Finish the whole object';

is $mock-connections, 0, 'All connections freed';

done-testing;
