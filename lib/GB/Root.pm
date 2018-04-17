
package GB::Root;

use strict;
use warnings;

use utf8;

use Plack;
use Plack::Request;
use Plack::Builder;

use FindBin qw($Bin);
use File::Spec::Functions qw(catfile);
use Text::Wrap;

use Encode;

use base qw(
	GB::Config
	GB::TT
	GB::DB
	GB::Logger
	GB::Captcha
);

sub new
{
    my ($class, %opts) = @_;
    my $self = bless (\%opts, ref ($class) || $class);

    return $self->init;
}

sub init {
	my $self=shift;

	$self->_log('init: ' . __PACKAGE__ );

	$self
		->GB::Logger::init()
		->GB::Config::init()
		->GB::TT::init()
		->GB::DB::init();

	$self;
}

sub _plack_req {
	my $self=shift;

	my $env = $self->{env} = shift;

	my $req    = Plack::Request->new($env);
	my $res    = $req->new_response(200);
	my $params = $req->parameters();

	@{$self}{qw(req res params)}=($req ,$res, $params);

	$self;
}

sub get_message {
	my $self = shift;

	my ($req,$res,$params)=@{$self}{qw(req res params)};

	my $body;

	my $dbh = $self->{dbh};
	if (keys %$params) {
		my $id = $params->{id};
		my $q = qq{
			select `msg` from `messages` where `id`=?
		};
		my $res = $dbh->selectall_arrayref($q,undef,$id);
		if (@$res) {
			my $msg = $res->[0]->[0];

			$self->tt_process('print_msg.tt',{ msg => $msg },\$body);
		}
	}

	$res->body($body);
	
	return $res->finalize();
}


sub add_message {
	my ($self,$ref) = @_;

	my $params = $ref->{params} || $self->{params} || {};
	my $tt     = $ref->{tt} || {};

	# Plack::Response instance
	my $res    = $self->{res};

	# Plack::Request instance
	my $req    = $self->{req};
	
	my $labels = $self->config_get_dict('/guestbook/layout/forms/add_message/labels/label');
	my $placeholders = $self->config_get_dict('/guestbook/layout/forms/add_message/placeholders/placeholder');

	my $body;
	if (keys %$params) {

		my %form_values;
		while(my($k,$v)=each %{$params}){
			$form_values{$k}= Encode::decode_utf8($v);
		}

		# captcha validation ########################
		my $captcha_user = $params->{captcha};
		my $captcha_pic  = $self->{captcha_pic};

		my( $c,$cc);
		#
		# Authen::Captcha instance
		$c            = $self->{captcha};

		my $fail=1;

		if ($c) {
			$cc=$c->check_code($captcha_user,$captcha_pic);
			if ($cc == 1) {
				$fail=0;
			}
		}

		if ( $fail ) {
			return 	$self->add_message({ 
					params => {},
					tt	 => {
						captcha_invalid => 'Цифры не совпадают, введите заново!',
						values          => \%form_values,
					},
				});
		}

		my $dbh=$self->{dbh};
		my $q = qq{
			insert into `messages` (
				`user`,`email`,`url`,`msg`,`user_ip`,`user_agent`,`time`
			) values (?,?,?,?,?,?,now())
		};
		my @v=( @{$params}{qw( user email url msg )}, $req->address, $req->user_agent );
		eval { $dbh->do($q,undef,@v) or do { $self->_error($dbh->errstr,$q); }; };
		if ($@) { $self->_error($@,$dbh->errstr,$q)  }
		$dbh->commit;

		$self->tt_process('index.tt',{ 
			info_msg       => 'Сообщение добавлено',
			%$tt
		},\$body
		);
	}else{

		my $img='';
		$self->GB::Captcha::generate({ img => \$img });

		my $form;
		$self->tt_process('forms/add_message.tt',{
			labels        => $labels,
			placeholders  => $placeholders,
			captcha => {
				img => $img
			},
			%$tt
		},\$form);
		
		$self->tt_process('index.tt',{ 
			form          => Encode::decode_utf8($form),
			jsfiles_local => [qw(add_message.js)],
		},\$body);
	}

	$res->body($body);
	
	return $res->finalize();
}

sub print_messages {
	my $self = shift;

	my $res=$self->{res};

	my $dbh=$self->{dbh};

	# columns for SQL select statement
	my $cols_db = $self->config_get_list('/guestbook/routes/print_messages/columns_db',{split => 1});

	# columns for html printing
	my $cols_html = $self->config_get_list('/guestbook/routes/print_messages/columns_html',{split => 1});

	my $h    = $self->config_get_dict('/guestbook/routes/print_messages/header_names/header');
	unless (keys %$h) {
		$self->_warn('Empty hash of header names for table list_msgs!');
		return $self;
	}

	my $f    = join ("," => map { '`'.$_.'`' } @$cols_db);

	my $q    = qq{ select $f  from `messages` };

	my @e=();
	my $sth;
	
	eval { $sth    = $dbh->prepare($q)
		or do { $self->_error($dbh->errstr,$q,@e); };
   	};
	if($@){ $self->_error($@,$dbh->errstr,$q,@e); }
	
	eval { $sth->execute(@e) or do { $self->_error($dbh->errstr,$q,@e); }; };
	if($@){ $self->_error($@,$dbh->errstr,$q,@e); }
	
	my $fetch='fetchrow_hashref';
	my ($msgs);
	my $wrap = $self->config_get_text('/guestbook/routes/print_messages/wrap') || 30;
	while (my $r=$sth->$fetch) {
		my %row=%$r;
		if (my $msg = $row{msg}) {

			$Text::Wrap::columns=int $wrap;
			my $w=wrap('','',$msg);
			my @m=split "\n" => $w;
			$row{msg_head} = shift @m;
		}

		push @$msgs,{%row};
	}

	my $msgs_page = $self->config_get_text('/guestbook/routes/print_messages/msgs_page');
	my $labels    = $self->config_get_dict('/guestbook/routes/print_messages/labels/label');

	my $body;
	$self->tt_process('list_msgs.tt',{ 
		jsfiles_local => [qw(list_msgs.js)],
		table_id  => 'table_list_msgs',
		msgs      => $msgs,
		msgs_page => $msgs_page,
		labels    => $labels,
		cols      => $cols_html,
		heads     => $h },
	\$body);
	$res->body($body);

	return $res->finalize();
	
}

sub mnt {
	my $self=shift;

	my $route=shift;

	mount "/$route" => builder { 
		sub { 
			$self->_plack_req(shift);
			$self->$route;
		} 
	};
}

sub run {
	my $self=shift;

	my $root_dir = $self->{root_dir};

	return builder {
		enable "Plack::Middleware::Static",
			path => qr{^/(js|css|images|json)/}, root => $root_dir;

		mount "/" => builder { 
			sub { 
				$self->_plack_req(shift);
				$self->{server}=$self->{req}->base;
				$self->{res}->redirect($self->{server}.'add_message');
				$self->{res}->finalize;
			} 
		};

		$self->mnt('add_message');
		$self->mnt('get_message');
		$self->mnt('print_messages');
	};
}

1;
 


