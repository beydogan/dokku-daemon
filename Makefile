# Assumes Ubuntu >= 14.04

.PHONY: install develop ci-dependencies test

install:
	go get
	go build main.go
	./dokku-daemon install

ci-dependencies: shellcheck bats

shellcheck:
ifeq ($(shell shellcheck > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	brew install shellcheck
else
	sudo add-apt-repository universe
	sudo apt-get update -qq && sudo apt-get install -qq -y shellcheck
endif
endif

bats:
ifeq ($(shell bats > /dev/null 2>&1 ; echo $$?),127)
ifeq ($(shell uname),Darwin)
	git clone https://github.com/sstephenson/bats.git /tmp/bats
	cd /tmp/bats && sudo ./install.sh /usr/local
	rm -rf /tmp/bats
else
	sudo add-apt-repository ppa:duggan/bats --yes
	sudo apt-get update -qq && sudo apt-get install -qq -y bats
endif
endif

setup-travis:
	wget -nv -O - https://packagecloud.io/gpg.key | apt-key add -
	echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/dokku.list
	apt-get update
	apt-get install -o Dpkg::Options::="--force-confold" --force-yes -y docker-engine
ifeq ($(DOKKU_VERSION),master)
	apt-get -y --no-install-recommends install "dokku"
else
	apt-get -y --no-install-recommends install "dokku=$(DOKKU_VERSION)"
endif

test:
	@bats tests
	@shellcheck bin/dokku-daemon
