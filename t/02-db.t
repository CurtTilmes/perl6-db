#!/usr/bin/env raku
use Test;
use DB::Mock;

plan 26;

isa-ok my $m = DB::Mock.new, DB::Mock, 'Create object';

is $m.execute('something'), 1, 'Execute a command';

is $mock-connections, 1, 'Connection got created';

is $mock-statements, 0, 'execute does not use statement';

is $mock-results, 0, 'execute does not use results';

is $m.connections.elems, 1, 'Connection got returned to the cache';

is $m.query('something').value, 1, 'query';

is $mock-connections, 1, 'Used same connection';

is $mock-statements, 1, 'Created statement, still alive';

is $mock-results, 0, 'Result got freed';

is $m.connections.elems, 1, 'Connection got returned to the cache';

isa-ok my $db = $m.db, DB::Mock::Connection, 'Get a new connection';

is $mock-connections, 1, 'Used same Connection';

lives-ok { $db.query('something').finish }, 'Execute command, finish result';

is $mock-statements, 1, 'Reused same Statement';

lives-ok { $db.query('something').finish }, 'Execute command, finish result';

is $mock-statements, 1, 'Reused same Statement';

is $m.connections.elems, 0, 'Empty Connection cache';

lives-ok { $db.finish }, 'Finish Connection';

is $m.connections.elems, 1, 'Connection got returned to Connection cache';

is $mock-statements, 1, 'Statement still in cache';

lives-ok { $m.query('another').finish }, 'Top level query';

lives-ok { $m.finish }, 'Finish Object';

is $mock-connections, 0, 'All Connections freed';

is $mock-statements, 0, 'All Statements freed';

is $mock-results, 0, 'All Results freed';

done-testing;
