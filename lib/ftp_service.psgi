use ftp_service::ftp_serviceImpl;

use ftp_service::ftp_serviceServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = ftp_service::ftp_serviceImpl->new;
    push(@dispatch, 'ftp_service' => $obj);
}


my $server = ftp_service::ftp_serviceServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
