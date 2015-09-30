name 'openvnet'
maintainer 'TIS Inc.'
maintainer_email 'ccndctr@gmail.com'
license 'All rights reserved'
description 'Installs/Configures openvnet'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

supports 'centos', '= 6.5'

depends 'openvswitch'
depends 'yum-epel'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'database'
