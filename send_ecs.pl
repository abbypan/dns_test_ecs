#!/usr/bin/perl

use Net::DNS;
use Net::IPAddress::Util qw( IP );
use POSIX;


my ($ns, $dom, $subnet) =@ARGV;

$resolver = new Net::DNS::Resolver(
	nameservers => [ $ns ],
	recurse     => 0,
	debug       => 1
);

$packet = new Net::DNS::Packet($dom, 'IN', 'A');
push @{$packet->{additional}}, gen_ecs_opt($subnet);
$packet->print;

print "-----------------------------\n";

$reply = $resolver->send( $packet );

sub gen_ecs_opt {
    my ($subnet) = @_;
    my $ecs_opt=new Net::DNS::RR(
        type =>'OPT', 
        flags=>0,
        rcode=>0,
    );
    my $ecs_val= gen_ecs_val($subnet);
    $ecs_opt->option( 8 => $ecs_val);
    return $ecs_opt;
}

sub gen_ecs_val {
    #RFC7871
    my ($subnet) = @_;
    my ($ip, $len) = split '/', $subnet;

    my $addr = IP($ip);
    my $bits = $ip !~ /:/ ? sprintf("%032b", $addr->as_n32()) : join('', $addr->explode_ip());

    my $pad_len = 4*ceil($len/4);
    my $cidr = substr $bits, 0, $pad_len;

    my $family = sprintf("%016b", $ip!~/:/ ? 1 : 2);
    my $src_prefix_len = sprintf("%08b", $len);
    my $scope_prefix_len = sprintf("%08b", 0);

    my $ecs_bits = join("", $family, $src_prefix_len, $scope_prefix_len, $cidr);
    my @ecs_bit_arr = $ecs_bits=~/(....)/g;
    my @ecs_hex = map { sprintf("%x", oct('0b'. $_)) } @ecs_bit_arr;
    my $ecs_val= pack('H*', join('', @ecs_hex)); 

    return $ecs_val;
}
