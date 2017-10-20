package ftp_service::ftp_serviceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org
our $VERSION = '1.0.0';
our $GIT_URL = 'https://github.com/kbaseapps/ftp_service.git';
our $GIT_COMMIT_HASH = '1de22f6a253549a9c1ed982be4c5a91a104f9888';

=head1 NAME

ftp_service

=head1 DESCRIPTION

A KBase module: ftp_service
This module serve as a service that lists files and file info in users private ftp space

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Workspace::WorkspaceClient;
use Config::IniFiles;
use Data::Dumper;
use POSIX;
use FindBin qw($Bin);
use JSON;
use LWP::UserAgent;
use Try::Tiny;
use XML::Simple;
use List::Util qw<first>;
use Cache::FileCache;
use Cache::MemoryCache;



sub curl_nodejs {
    my ($file_link, $user_token) = @_;
    my $cmd   = 'curl --connect-timeout 100 -si';
    $cmd     .= " -H 'Authorization: $user_token' $file_link";
		my ($head,$body)  = split( m{\r?\n\r?\n}, `$cmd`) or die "Connection timed out retreving file list:\n";
		my ($code) = $head =~m{\A\S+ (\d+)};
		$code == 200 or die "Error retreving data from nodejs service: Return code $code \n".$body."\n";
		my $json  = decode_json($body);
		return $json;
}

sub search_files {
	my ($response, $search_string) = @_;
	my %search_hash;
	for (my $i=0; $i<@{$response}; $i++){
		my $file_name = lc($response->[$i]->{name});
		my $each_file = {
			file_link => $response->[$i]->{path},
			file_name => $response->[$i]->{name},
			file_size => $response->[$i]->{size},
			isFolder => encode_json($response->[$i]->{isFolder})
		};
		$search_hash{$file_name} = $each_file;
	}
	my $st = lc ($search_string);
	my $regex = qr/$st*/;
	my @keys = grep { /$regex/ } keys %search_hash;
	my $file_list = [];
	foreach my $k (@keys){
		push ($file_list, $search_hash{$k});
	};
	return $file_list;
}

sub return_file_list {
	my ($response) = @_;
	my $file_path_list = [];
	for (my $i=0; $i<@{$response}; $i++){
		my $file_name = lc($response->[$i]->{name});
		my $each_file = {
			file_link => $response->[$i]->{path},
			file_name => $response->[$i]->{name},
			file_size => $response->[$i]->{size},
			isFolder => encode_json($response->[$i]->{isFolder})
		};
    if (encode_json($response->[$i]->{isFolder}) eq 'false'){
		 push ($file_path_list, $response->[$i]->{name});
    }
	}
  return $file_path_list;
}

#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('ftp_service','workspace-url');
    die "no workspace-url defined" unless $wsInstance;

    $self->{'workspace-url'} = $wsInstance;

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 search_list_files

  $output = $obj->search_list_files($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ftp_service.listFilesInputParams
$output is a ftp_service.searchListFilesOutputPparams
listFilesInputParams is a reference to a hash where the following keys are defined:
	token has a value which is a string
	type has a value which is a string
	search_word has a value which is a string
	username has a value which is a string
searchListFilesOutputPparams is a reference to a hash where the following keys are defined:
	files has a value which is a reference to a list where each element is a ftp_service.fileInfo
	username has a value which is a string
fileInfo is a reference to a hash where the following keys are defined:
	file_link has a value which is a string
	file_name has a value which is a string
	file_size has a value which is a float
	file_type has a value which is a string
	isFolder has a value which is a string
	date has a value which is a string

</pre>

=end html

=begin text

$params is a ftp_service.listFilesInputParams
$output is a ftp_service.searchListFilesOutputPparams
listFilesInputParams is a reference to a hash where the following keys are defined:
	token has a value which is a string
	type has a value which is a string
	search_word has a value which is a string
	username has a value which is a string
searchListFilesOutputPparams is a reference to a hash where the following keys are defined:
	files has a value which is a reference to a list where each element is a ftp_service.fileInfo
	username has a value which is a string
fileInfo is a reference to a hash where the following keys are defined:
	file_link has a value which is a string
	file_name has a value which is a string
	file_size has a value which is a float
	file_type has a value which is a string
	isFolder has a value which is a string
	date has a value which is a string


=end text



=item Description



=back

=cut

sub search_list_files
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to search_list_files:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_list_files');
    }

    my $ctx = $ftp_service::ftp_serviceServer::CallContext;
    my($output);
    #BEGIN search_list_files
    my ($token, $user_name);
		if (defined $params->{token} && defined $params->{username}){
			$token=$params->{token};
			$user_name = $params->{username};
		}
		else{
			die "KBase username or token is not identified\n";
		}

    my $ftp_url = 'https://ci.kbase.us/services/kb-ftp-api/v0/list/'.$user_name.'/';

		my $cache = Cache::MemoryCache->new( { 'namespace' => 'temp',
                                        'default_expires_in' => 30 } );
		my $response = $cache->get('temp');
  	if ( !defined $response ){
			$cache->clear();
			$response = curl_nodejs($ftp_url, $token);
    		$cache->set( 'temp', $response );
  	}
		if ($params->{search_word}){
			my $file_list = search_files ($response, $params->{search_word});
			$output = {
				files => $file_list,
				username => $user_name
			};
	  }
		else{
			die "search word not defined !\n\n";
		}

		print &Dumper ($output);
		return $output;
    #END search_list_files
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to search_list_files:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_list_files');
    }
    return($output);
}




=head2 list_files

  $return = $obj->list_files($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a ftp_service.listFilesInputParams
$return is a ftp_service.filepathList
listFilesInputParams is a reference to a hash where the following keys are defined:
	token has a value which is a string
	type has a value which is a string
	search_word has a value which is a string
	username has a value which is a string
filepathList is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a ftp_service.listFilesInputParams
$return is a ftp_service.filepathList
listFilesInputParams is a reference to a hash where the following keys are defined:
	token has a value which is a string
	type has a value which is a string
	search_word has a value which is a string
	username has a value which is a string
filepathList is a reference to a list where each element is a string


=end text



=item Description



=back

=cut

sub list_files
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to list_files:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_files');
    }

    my $ctx = $ftp_service::ftp_serviceServer::CallContext;
    my($return);
    #BEGIN list_files
    my $ftp_url = 'https://ci.kbase.us/services/kb-ftp-api/v0/list/'.$params->{username}.'/';
    print "$ftp_url\n";

	my $response = curl_nodejs($ftp_url, $ctx->{token});
    my $data = return_file_list ($response);
    #print &Dumper ($data);
    return $data;
    #END list_files
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to list_files:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'list_files');
    }
    return($return);
}




=head2 status

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
}

=head1 TYPES



=head2 listFilesInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
token has a value which is a string
type has a value which is a string
search_word has a value which is a string
username has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
token has a value which is a string
type has a value which is a string
search_word has a value which is a string
username has a value which is a string


=end text

=back



=head2 fileInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
file_link has a value which is a string
file_name has a value which is a string
file_size has a value which is a float
file_type has a value which is a string
isFolder has a value which is a string
date has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
file_link has a value which is a string
file_name has a value which is a string
file_size has a value which is a float
file_type has a value which is a string
isFolder has a value which is a string
date has a value which is a string


=end text

=back



=head2 searchListFilesOutputPparams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
files has a value which is a reference to a list where each element is a ftp_service.fileInfo
username has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
files has a value which is a reference to a list where each element is a ftp_service.fileInfo
username has a value which is a string


=end text

=back



=head2 filepathList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=cut

1;
