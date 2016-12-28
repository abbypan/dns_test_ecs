# dns_test_ecs
test RFC7871  edns client subnet

## install

    cpanm -n -f Net::DNS;
    cpanm -n -f Net::IPAddress::Util
    cpanm -n -f Net::DNS::Nameserver

## send_ecs

    $ perl send_ecs.pl 8.8.8.8 www.google.com 202.38.64.0/24

same as : 

    $ dig @8.8.8.8 www.google.com +subnet=202.38.64.0/24

## recv_ecs 

example from Net::DNS::Nameserver

## dns-reply-missing-edns.patch

Net::DNS 1.06

fix bug : [Net::DNS::Nameserver does not allow EDNS replies](https://rt.cpan.org/Ticket/Display.html?id=115558&results=b726149ec96a4ba3ede1c65761e1a229)
