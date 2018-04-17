


package GB::TT;

use strict;
use warnings;

use Template;

use File::Spec::Functions qw(catfile);
use Data::Dumper qw(Dumper);

use Encode;

sub init {
	my $self=shift;

	$self->_log('init: ' . __PACKAGE__ );

	my $root_dir     = $self->{root_dir};
	my $include_path = catfile($root_dir,qw(templates));

    my $h={
		tt_config => {
			INCLUDE_PATH => $include_path,
			INTERPOLATE  => 1,               # expand "$var" in plain text
			POST_CHOMP   => 1,               # cleanup whitespace
			EVAL_PERL    => 1,               # evaluate Perl code blocks
			ENCODING     => 'utf8',
			DEFAULT_ENCODING => 'utf8',
		}
	};

	my @k=keys %$h;
	
	for(@k){ $self->{$_} = $h->{$_} unless defined $self->{$_}; }

	$self->{tt}=$self->tt_new;

	$self;

}

sub tt_new {
	my $self=shift;

	my $config = $self->{tt_config} || {};
	Template->new($config);
}

sub tt_process {
	my $self=shift;

	my ($template,$vars,$ref)=@_;

	my $tt     = $self->{tt} || $self->tt_new;

	my $nodes_links = $self->{nodes_links} ||= $self->config_get_nodes('/guestbook/layout/header/links/link');
	my $links=[];
	foreach my $node (@$nodes_links) {
		my $link={};

		foreach(qw(title url)) {
			$link->{$_}=$node->getAttribute($_);
		}
		push @$links,$link;
	}

	my $req=$self->{req};
	$vars={
		%$vars,
		base_href => $self->{server},
		links     => $links,
	};
	
	$tt->process( $template, $vars, $ref, { binmode => ':utf8' })
		|| do { 
				my $error = $tt->error();
				my @e;
				push @e, 
					'Failure to process template: ' . $template,
					"TT error type: ", $error->type(),
	            	"TT error info: ", $error->info(),
					$error;
				$self->_error(@e);
		};
	${$ref} = Encode::encode_utf8(${$ref});

	$self;
}

1;
 

