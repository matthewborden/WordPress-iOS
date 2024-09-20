#!/bin/bash -eu
APP=${1:-}

export BUILDKITE_CACHE_MOUNT_PATH="$NSC_CACHE_PATH"
export BUILDKITE_AGENT_CACHE_PATHS="vendor/bundle,Pods,~/Library/Caches/CocoaPods/,~/.cocoapods,$HOME/Library/Caches/org.swift.swiftpm"
.buildkite/commands/cache.sh restore "rubygems-{{ checksum \"Gemfile.lock\" }}-podfile-{{ checksum \"Podfile.lock\" }}"

# Run this at the start to fail early if value not available
if [[ "$APP" != "wordpress" && "$APP" != "jetpack" ]]; then
  echo "Error: Please provide either 'wordpress' or 'jetpack' as first parameter to this script"
  exit 1
fi

echo "--- :beer: Installing Homebrew Dependencies"
brew tap FelixHerrmann/tap
brew install swift-package-list

echo "--- :rubygems: Setting up Gems"
bundle install

echo "--- :cocoapods: Setting up Pods"
bundle exec pod install

echo "--- :writing_hand: Copy Files"
mkdir -pv ~/.configure/wordpress-ios/secrets
cp -v fastlane/env/project.env-example ~/.configure/wordpress-ios/secrets/project.env

echo "--- :closed_lock_with_key: Installing Secrets"
# bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Building"
bundle exec fastlane build_${APP}_for_testing


echo "--- :arrow_up: Upload Build Products"

echo "Compressing archive"
tar -czf build-products-${APP}.tar DerivedData/Build/Products/
echo "Finished compressing archive"
buildkite-agent artifact upload build-products-${APP}.tar

.buildkite/commands/cache.sh save "rubygems-{{ checksum \"Gemfile.lock\" }}-podfile-{{ checksum \"Podfile.lock\" }}"
