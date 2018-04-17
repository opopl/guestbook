
# GB - Simple GuestBook Plack App written in Perl

## Installation

Dependencies are written in Makefile.PL

## Usage

### Via build-in Plack server

Application may be started locally:

    plackup guestbook.psgi

### Via Apache2 & mod_perl

	Add this somewhere inside an Apache2 config file

		<Location /guestbook/ >
			SetHandler perl-script
			PerlResponseHandler Plack::Handler::Apache2
			PerlSetVar psgi_app "( path to guestbook.psgi )"
		</Location>

## Routes

	/                  - redirects to /add_message
	/add_message       - add a new message to the database
	/print_messages    - print all available messages
	/get_message?id=ID - print the contents of the message with specific ID

## Modules

* GB::Root    - main guestbook module
* GB::Captcha - captcha generation, implemented server-side by
										CPAN Authen::Captcha module
* GB::Config  - configuration handling
* GB::TT      - Template::Toolkit handling
* GB::Logger  - internal guestbook logger
* GB::DB      - mysql database initialization via DBI

## SQL databases

	MySQL needs to be installed.

* database: guestbook
* table: messages

	See sql/init.sql on the table definition.

## Configuration

All configuration is stored in the file "config.xml"
stored in the root directory of the project.

## Templates

	This app employs the TT (Template::Toolkit) templating engine.
	All templates are stored in templates/ subdirectory.
	Forms are stored in templates/forms/.

## Environments

	This app has been tested on:
		MS Windows 8, Apache 2.4, mod_perl 2.0.10, Strawberry perl 5.24.1 64bit

	Not yet tested on Linux

## TODO

* Add administration of the guest book via login form
* Add possibility to delete/modify records within the table
		(checking of individual/all records has been already implemented)
* Improve internal error handling
* Improve CAPTCHA handling ( e.g. modules: GD::SecurityImage, Captcha::reCAPTCHA )

## Copyright

Oleksandr Poplavskyy ( op@cantab.net ), 2018


