# Refresh package lists
opkg update

# Install kapture dependencies from angstrom precompiled packages
opkg install \
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
  g++ \
  g++-symlinks \
  openssl \
  openssl-dev \

#removed hotplug
#task-proper-tools \
#task-base-extended \
#angstrom-led-config \
#zd1211-firmware \
#rt73-firmware \

# Install ruby
cd ~
mkdir ruby
cd ruby
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p378.tar.gz
tar zxvf ruby-1.9.1-p378.tar.gz
cd ruby-1.9.1-p378
./configure
make && make install


# install rubygems dependencies
cd ~ 
gem update --system
gem install gemcutter
gem tumble
gem install RubyInline jeweler rails hoe rspec will_paginate thin sqlite3-ruby haml gphoto4ruby


# compile dcraw - conversion from RAW to jpeg
cd ~
mkdir dcraw
cd dcraw
wget http://www.cybercom.net/~dcoffin/dcraw/dcraw.c
gcc -o dcraw -O4 dcraw.c -lm -ljpeg -llcms
cp dcraw /usr/bin/dcraw


# Install image science gem
cd ~
git clone git://github.com/tdd/image_science.git
cd image_science
rubyforge setup
rake install_gem
gem install --local pkg/image_science-1.2.1.tdd.gem 



# install kapture project
cd ~
git clone git://github.com/tallakt/kapture.git
cd kapture


# configuration of kapture
RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate


rake daemon:install

/etc/init.d/kaptured start
/etc/init.d/thin start






