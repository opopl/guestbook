package GB::Config;

use strict;
use warnings;

use XML::LibXML;
use File::Spec::Functions qw(catfile);

my $trim=sub{
	local $_=shift;
	s/^\s*//g; s/\s*$//g; $_;
};

sub init {
	my ($self,$ref) = @_;

	$self->_log('init: ' . __PACKAGE__ );

	my $root_dir = $self->{root_dir};

	my $config = catfile($root_dir,qw(config.xml));

	my $prs = XML::LibXML->new;
	
	open my $fh, '<:encoding(utf8)', $config;
	binmode $fh;
	my $inp={
		IO          	=> $fh,
		recover         => 1,
		suppress_errors => 1,
	};
	$self->{dom_config} = $prs->load_xml(%$inp);
	close $fh;
	
	$self;
}

sub config_get_nodes {
	my ($self,$xpath)=@_;

	my $dom = $self->{dom_config};

	my @nodes = $dom->findnodes($xpath);

	wantarray ? @nodes : \@nodes ;
}

sub config_get_list {
	my ($self,$xpath,$opts)=@_;

	$opts ||= {};
	$opts->{sep} ||= ",";

	my $dom = $self->{dom_config};
	my $list=[];
	my $trim=sub{
		local $_=shift;
		s/^\s*//g; s/\s*$//g; ($_) ? $_ : ();
	};
	$dom->findnodes($xpath)->map(
		sub { 
			my $node=shift; 
			my $content = $node->textContent || '';

			if ($opts->{split}) {
				push @$list,map { $trim->($_) } split($opts->{sep},$content);
			}else{
				push @$list,map { $trim->($_) } ( $content );
			}
		}
	);

	wantarray ? @$list : $list ;
	
}

sub config_get_attr {
	my ($self,$xpath,$opts)=@_;

	$opts ||= {};

	my $attr_names = $opts->{attr} || [];

	my $dom = $self->{dom_config};

	my @attr_values;
	$dom->findnodes($xpath)->map(
		sub { 
			my $node=shift; 
			push @attr_values, map { $trim->($_)} map { $node->getAttribute($_) } @$attr_names;
		}
	);

	wantarray ? @attr_values : [@attr_values] ;
	
}

sub config_get_dict {
	my ($self,$xpath)=@_;

	my $dom = $self->{dom_config};
	my $node_dict = sub {
		my ($node,$xpath)=@_;
		my $dict={};

		$node->findnodes($xpath)->map(
			sub { 
				my $node=shift; 
				my ($key,$value) = map { $node->getAttribute($_) } qw(key value);
				if ($key) {
					$dict->{$key}=$value;
				}
				$node->findnodes('./child::*')->map(sub{
					my $node=shift;
					my $name = $node->nodeName;
					my $text = $node->textContent || '';
					$dict->{$name}=$text;
				});
			}
		);
		return $dict;
	};

	my $dict=$node_dict->($dom,$xpath);

	return $dict;	
}

sub config_get_text {
	my ($self,$xpath)=@_;

	my $dom = $self->{dom_config};
	my $text='';
	$dom->findnodes($xpath)->map(
		sub { 
			my $node=shift; 
			my $cnt = $node->textContent || '';
			$cnt = $trim->($cnt);
			$text.=$cnt if $cnt;
		}
	);

	return $text;	
}

1;
 

