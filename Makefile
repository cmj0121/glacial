SUBDIR  :=

.PHONY: all clean test run build release upgrade help $(SUBDIR)

all: $(SUBDIR) 		# default action
	@[ -f .git/hooks/pre-commit ] || pre-commit install --install-hooks
	@git config commit.template .git-commit-template

clean: $(SUBDIR)	# clean-up environment
	@find . -name '*.sw[po]' -delete
	flutter clean

test:				# run test
	cd ios && fastlane e2e
	cd macos && fastlane e2e

run:				# run in the local environment
	flutter run

build:				# build the binary/library
	cd ios && fastlane build

release:			# build the release binary/library
	# dart run flutter_launcher_icons -f pubspec.yaml
	cd macos && fastlane bump_version && fastlane release
	cd ios   && fastlane release

upgrade:			# upgrade all the necessary packages
	pre-commit autoupdate

help:				# show this message
	@printf "Usage: make [OPTION]\n"
	@printf "\n"
	@perl -nle 'print $$& if m{^[\w-]+:.*?#.*$$}' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?#"} {printf "    %-18s %s\n", $$1, $$2}'

$(SUBDIR):
	$(MAKE) -C $@ $(MAKECMDGOALS)
