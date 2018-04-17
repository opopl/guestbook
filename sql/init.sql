
set names utf8;

create table if not exists `messages` (
  `id` int(11) not null auto_increment,
  `user` varchar(255) not null,
  `email` varchar(255) not null,
  `msg` text not null,
  `url` varchar(255),
  `user_ip` varchar(255),
  `user_agent` varchar(255),
  `time` datetime,
  primary key (`id`)
) engine=myisam default charset=utf8;
