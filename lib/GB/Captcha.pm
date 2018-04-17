package GB::Captcha;

use strict;
use warnings;

use Authen::Captcha;
use File::Spec::Functions qw(catfile);
use File::Path qw(mkpath);

sub generate {
	my $self = shift;

	my $ref  = shift;

	my $root_dir=$self->{root_dir};

	my $config_captcha = $self->config_get_dict('/guestbook/layout/forms/add_message/captcha');

	my $img_folder      = $config_captcha->{img_folder};
	my $img_folder_full = catfile($root_dir,$img_folder);

	my $data_folder     = $config_captcha->{data_folder}; 
	my $data_folder_full = catfile($root_dir,$data_folder);

	mkpath $data_folder_full unless -d $data_folder_full;
	mkpath $img_folder_full unless -d $img_folder_full;
	
	my $c = $self->{captcha} = Authen::Captcha->new(
		data_folder   => $data_folder_full,
		output_folder => $img_folder_full,
	);
	
	my $num_symbols = int ($config_captcha->{num_symbols}) || 5;
	$num_symbols=5;

	# create a captcha. Image filename is "$token.png"
	my $token = $c->generate_code($num_symbols);
	my $img   = $img_folder.$token.'.png';
	
	$self->{captcha_pic}=$token;

	${$ref->{img}}=$img;

	$self;
}


1;
 

