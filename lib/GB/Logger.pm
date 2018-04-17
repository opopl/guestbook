
package GB::Logger;

use strict;
use warnings;

use Log::Any qw($log);
use Log::Any::Adapter;
use File::Spec::Functions qw(catfile);

sub init {
	my $self=shift;

	my $root_dir = $self->{root_dir};

    Log::Any::Adapter->set('File', catfile($root_dir,qw(guestbook.log) ));

	$self;
}

sub _warn {
	my $self = shift;

	for(@_){
		$log->warn($_);
	}
	
	$self;
}

sub _log {
	my $self = shift;

	for(@_){
		$log->info($_);
	}
	
	$self;
}


sub _error {
	my $self = shift;

	die $log->fatal(join("\n",@_));
}


1;
 

