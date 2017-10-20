use strict;
use Data::Dumper;
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use Workspace::WorkspaceClient;
use ftp_service::ftp_serviceImpl;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('ftp_service');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new Workspace::WorkspaceClient($ws_url,token => $token);
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1);
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$ftp_service::ftp_serviceServer::CallContext = $ctx;
my $impl = new ftp_service::ftp_serviceImpl();


my $input_args = {
  username => 'janakakbase',
  type => '',
  search_word => 'fastq',
  #token =>'un=janakakbase|tokenid=77bd0b06-b8c8-11e6-b423-22000aef184d|expiry=1512244182|client_id=janakakbase|token_type=Bearer|SigningSubject=https://nexus.api.globusonline.org/goauth/keys/f5a9a7ea-b8b9-11e6-8d8f-22000ab80e73|sig=3d2daef913764bcdddd82c2cb140edf541ada2d6ec65cda9adea6cb881f9d1d3896b6dce687c383fb6f6908c41bc57a5d26832c3a91f804d91a20c96850f664189ae25c1a964c2212ab93e29958f28c6ce5d8854fca588df3e9eee788f2708a491f5c769d86f18fb60335a22393eb8ebcdbe2a1aeecffbc5f508fbe03ee7edab'
  token => "TNDRXPOIFZ6RVIJIQOV4PLMXRCV6XHAG"
};

eval {
   #my $ret =$impl->list_files($input_args);

   my $ret =$impl->search_list_files ($input_args);
};

=head

sub get_ws_name {
    if (!defined($ws_name)) {
        my $suffix = int(time * 1000);
        $ws_name = 'test_ftp_service_' . $suffix;
        $ws_client->create_workspace({workspace => $ws_name});
    }
    return $ws_name;
}

eval {
    my $obj_name = "contigset.1";
    my $contig1 = {id => '1', length => 10, md5 => 'md5', sequence => 'agcttttcat'};
    my $contig2 = {id => '2', length => 5, md5 => 'md5', sequence => 'agctt'};
    my $contig3 = {id => '3', length => 12, md5 => 'md5', sequence => 'agcttttcatgg'};
    my $obj = {contigs => [$contig1,$contig2,$contig3], id => 'id', md5 => 'md5',
            name => 'name', source => 'source', source_id => 'source_id', type => 'type'};
    $ws_client->save_objects({workspace => get_ws_name(), objects =>
            [{type => 'KBaseGenomes.ContigSet', name => $obj_name, data => $obj}]});
    my $ret = $impl->filter_contigs({workspace=>get_ws_name(), contigset_id=>$obj_name,
            min_length=>"10"});
    ok($ret->{n_initial_contigs} eq 3, "number of initial contigs");
    ok($ret->{n_contigs_removed} eq 1, "number of removed contigs");
    ok($ret->{n_contigs_remaining} eq 2, "number of remaining contigs");
    $@ = '';
    eval {
        $impl->filter_contigs({workspace=>get_ws_name(), contigset_id=>"fake",
                min_length=>10});
    };
    like($@, qr/Error loading original ContigSet object/);
    eval {
        $impl->filter_contigs({workspace=>get_ws_name(), contigset_id=>"fake",
                min_length=>"-10"});
    };
    like($@, qr/min_length parameter shouldn\'t be negative/);
    eval {
        $impl->filter_contigs({workspace=>get_ws_name(), contigset_id=>"fake"});
    };
    like($@, qr/Parameter min_length is not set in input arguments/);
    done_testing(6);
};

=cut
my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
if (defined($err)) {
    if(ref($err) eq "Bio::KBase::Exceptions::KBaseException") {
        die("Error while running tests: " . $err->trace->as_string);
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'ftp_service', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
}
