use Test::More tests => 5;

use strict;
use warnings;

BEGIN { use_ok('Zabbix::API::Utils', qw/RE_FORMULA RE_EXPRESSION/); }

my $re_formula = RE_FORMULA;

my $string_simple = q{last("alpha")+first("beta")+average("gamma")};

my @match_simple = try_regexp($string_simple);

is_deeply(\@match_simple,
          [ { function_call => 'last("alpha")',
              function_args => 'alpha',
              function_args_quote => '"' },
            { function_call => 'first("beta")',
              function_args => 'beta',
              function_args_quote => '"' },
            { function_call => 'average("gamma")',
              function_args => 'gamma',
              function_args_quote => '"' }, ],
          '... and a simple, correct formula is parsed');

my $string_complex = q{last("Zabbix Server:net.if.in[eth0,bytes]")+last("Zibbax Server:do.stuff[bytes,lo0]")-blah("Nono le Robot:reticulate.splines[eth2,clous]")};

my @match_complex = try_regexp($string_complex);

is_deeply(\@match_complex,
          [ { function_call => 'last("Zabbix Server:net.if.in[eth0,bytes]")',
              function_args => 'Zabbix Server:net.if.in[eth0,bytes]',
              function_args_quote => '"',
              host => 'Zabbix Server',
              item => 'net.if.in',
              item_arg => 'eth0,bytes' },
            { function_call => 'last("Zibbax Server:do.stuff[bytes,lo0]")',
              function_args => 'Zibbax Server:do.stuff[bytes,lo0]',
              function_args_quote => '"',
              host => 'Zibbax Server',
              item => 'do.stuff',
              item_arg => 'bytes,lo0' },
            { function_call => 'blah("Nono le Robot:reticulate.splines[eth2,clous]")',
              function_args => 'Nono le Robot:reticulate.splines[eth2,clous]',
              function_args_quote => '"',
              host => 'Nono le Robot',
              item => 'reticulate.splines',
              item_arg => 'eth2,clous' }, ],
          '... and a complex, correct formula is parsed');

my $trigger_simple = '{www.zabbix.com:system.cpu.load[all,avg1].last(0)}>5';

my $re_expression = RE_EXPRESSION;

like($trigger_simple, $re_expression, '... and a simple, correct expression is parsed');

$trigger_simple =~ m/$re_expression/;

is_deeply(\%+,
          { operator => '>',
            operand => '{www.zabbix.com:system.cpu.load[all,avg1].last(0)}',
            host => 'www.zabbix.com',
            item => 'system.cpu.load',
            item_arg => 'all,avg1',
            function => 'last(0)', },
          '... and the captures are correct');

sub try_regexp {

    my $string = shift;

    my @matches;

    while ($string =~ m/$re_formula/g) {

        my %foo = %+;
        push @matches, (\%foo);

    }

    return @matches;

}
