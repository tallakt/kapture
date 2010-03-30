opkg update
opkg install \
	hotplug \
	task-proper-tools \
	task-base-extended \
	angstrom-led-config \
	zd1211-firmware \
	rt73-firmware \
	make  \
	gcc  \
	gcc-symlinks  \
	binutils  \
	binutils-symlinks  \
	cpp  \
	cpp-symlinks  \
	libc6-dev \
	openssh-scp \
	openssh-ssh \
	libsqlite3-0 \
	libsqlite3-dev \
	sqlite3 \
	libfreeimage3 \
	freeimage \
	git \
	libjpeg-tools  \
	lcms \
	lcms-dev \
	gphoto2-dev \
	libgphoto2-dev \

#opkg install /media/mmcblk0p1/ipk/ruby_1.9.1-p378-r1.1_armv7a.ipk 
cd ~
mkdir ruby
cd ruby
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p378.tar.gz
tar zxvf ruby-1.9.1-p378.tar.gz
cd ruby-1.9.1-p378
./configure
make && make install


cd ~ 
gem update-system
gem install gemcutter
gem tumble
gem install RubyInline jeweler rails hoe rspec will_paginate thin sqlite3-ruby haml


cd ~
mkdir dcraw
cd dcraw
wget http://www.cybercom.net/~dcoffin/dcraw/dcraw.c
gcc -o dcraw -O4 dcraw.c -lm -ljpeg -llcms
cp dcraw /usr/bin/dcraw


cd ~
sudo apt-get install libgphoto2-2-dev
git clone git://github.com/tallakt/gphoto4ruby.git
cd gphoto4ruby
git fetch origin eos_40D_bugs:eos_40D_bugs
git checkout -b eos_40D_bugs
rake install

cd ~
sudo apt-get install libfreeimage-dev libfreeimage3
git clone git://github.com/tdd/image_science.git
cd image_science
rake install_gem


cd ~
git clone git://github.com/tallakt/kapture.git
cd kapture


RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate


rake daemon:install

/etc/init.d/kaptured start
/etc/init.d/thin start






