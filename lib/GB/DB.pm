
package GB::DB;

use strict;
use warnings;

use DBI;
use SQL::SplitStatement;

use File::Slurp qw(read_file);
use File::Spec::Functions qw(catfile);

sub init {
	my $self=shift;

	$self->_log('init: ' . __PACKAGE__ );

	my $root_dir = $self->{root_dir};

	my ($dsn,$db,$user,$pwd);
	my $attr = $self->config_get_dict('/guestbook/db/dbi/attr');
	my $conn = $self->config_get_dict('/guestbook/db/dbi/connect');

	$conn->{host} ||= 'localhost';
	
	$conn->{dsn} ||= "DBI:mysql:database=".$conn->{database}.";host=".$conn->{host};

	my $dbh = $self->{dbh} = DBI->connect( @{$conn}{qw(dsn user password)} ,$attr)
	    || $self->_error($DBI::errstr);

	my $sqlfiles = $self->config_get_list('/guestbook/db/init/read_sql/file');
	my ($dir)    = $self->config_get_attr('/guestbook/db/init/read_sql',{attr  => [qw(dir)] });
	$dir = '' unless defined $dir;

	my $spl = SQL::SplitStatement->new;
	foreach my $f (@$sqlfiles) {
		my $file=catfile($root_dir,$dir,$f);
		unless (-e $file) {
			$self->_warn('NO SQL file:',$file);
			next;
		}
		my $sql=read_file( $file, binmode => ':utf8' );
		
		my @q = $spl->split($sql);
		foreach my $q (@q) {
			eval { $dbh->do($q) or $self->_error($dbh->errstr,$q); };
			if ($@) { $self->_error($@,$dbh->errstr,$q);  }
		}

		$self->_log('processed SQL init file: ', $file );
	}

	$self;

}


1;
 
