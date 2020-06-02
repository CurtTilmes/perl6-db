#!/usr/bin/env raku
use Test;
use DB::Mock;

plan 35;

isa-ok my $m = DB::Mock.new, DB::Mock, 'Create object';

isa-ok my $sth = $m.db.prepare('something'), DB::Mock::Statement, 'Prepare';

is $mock-statements, 1, 'Prepared 1 statement';

is-deeply $sth.execute(1).array,
          (1, 'string 1', Any),
    'Array';

is $mock-statements, 1, 'Statement still around';

is $mock-results, 0, 'Result got freed';

is-deeply $sth.execute(1).hash,
          %( a => 1, b => 'string 1', c => Any ),
          'Hash';

is-deeply $sth.execute(3).arrays,
    ((1, 'string 1', Any),
     (2, 'string 2', Any),
     (3, 'string 3', Any)),
    'Arrays';

is-deeply $sth.execute(3).hashes,
    (%( a => 1, b => 'string 1', c => Any),
     %( a => 2, b => 'string 2', c => Any),
     %( a => 3, b => 'string 3', c => Any)),
    'Hashes';

is $m.connections.elems, 0, 'Executes did not return to cache yet';

lives-ok { $sth.finish }, 'Statement finish';

is $m.connections.elems, 1, 'Connection returned to cache';

isa-ok my $db = $m.db, DB::Mock::Connection, 'Get connection';

isa-ok my $sth1 = $db.prepare('this 1'), DB::Mock::Statement, 'Statement 1';

isa-ok my $sth2 = $db.prepare('this 2'), DB::Mock::Statement, 'Statement 2';

isa-ok my $sth3 = $db.prepare('this 3'), DB::Mock::Statement, 'Statement 3';

is $mock-connections, 1, 'Still just 1 connection in use';

is $mock-statements, 4, '4 Statements should be live now';

is $sth1.execute(1).value, 1, 'value execute 1';

isa-ok my $res2 = $sth2.execute(), DB::Mock::Result, 'Keep the result 2';

isa-ok my $res3 = $sth3.execute(), DB::Mock::Result, 'Keep the result 3';

is $mock-results, 2, '2 Results still around';

is-deeply $res2.array, (1, 'string 1', Any), 'Get result from 2';

is $mock-results, 1, '1 Result still around';

lives-ok { $res3.finish }, 'Finish result 3 without retrieving';

is $mock-results, 0, 'All results freed';

is $m.connections.elems, 0, 'But connection not yet finished';

lives-ok { $sth1.finish }, 'Finish statement same as finish connection';

is $m.connections.elems, 1, 'Connection back in cache';

is $mock-statements, 4, 'But all statements still prepared and cached';

$db = $m.db;       # Get the connection;

$db.state = False; # Intentionally kill it

$db.finish;        # and return it

is $mock-connections, 0, 'No connections';

is $mock-statements, 0, 'No statements';

is $mock-results, 0, 'No results';

is $m.connections.elems, 0, 'And no connections cache';

lives-ok { $m.finish }, 'Finish the object';
