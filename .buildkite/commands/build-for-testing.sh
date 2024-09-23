#!/bin/bash -eu
APP=${1:-}

aws s3 cp s3://$ARTIFACT_BUCKET/zstash/zstash_Darwin_arm64.tar.gz .bin/zstash_Darwin_arm64.tar.gz
tar -xzf .bin/zstash_Darwin_arm64.tar.gz -C .bin
# sudo xattr -d com.apple.quarantine .bin/zstash
chmod +x .bin/zstash

echo "--- :zstash: Restoring Cache"
.bin/zstash restore --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./Gemfile.lock" }}-ruby' \
  vendor/bundle

.bin/zstash restore --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./Podfile.lock" }}-pods' \
  Pods

.bin/zstash restore --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./WordPress.xcworkspace/xcshareddata/swiftpm/Package.resolved" }}-spm' \
  "${HOME}/Library/Caches/org.swift.swiftpm"

# Run this at the start to fail early if value not available
if [[ "$APP" != "wordpress" && "$APP" != "jetpack" ]]; then
  echo "Error: Please provide either 'wordpress' or 'jetpack' as first parameter to this script"
  exit 1
fi


echo "--- :beer: Installing Homebrew Dependencies"
brew tap FelixHerrmann/tap
brew install swift-package-list

echo "--- :rubygems: Setting up Gems"
bundle install --path vendor/bundle

echo "--- :cocoapods: Setting up Pods"
bundle exec pod install

echo "--- :writing_hand: Copy Files"
mkdir -pv ~/.configure/wordpress-ios/secrets
cp -v fastlane/env/project.env-example ~/.configure/wordpress-ios/secrets/project.env

echo "--- :swift: Setting up Swift Packages"
swift package

echo "--- :hammer_and_wrench: Building"
bundle exec fastlane build_${APP}_for_testing

# echo "--- :arrow_up: Upload Build Products"
# tar -cf build-products-${APP}.tar DerivedData/Build/Products/
# upload_artifact build-products-${APP}.tar

echo "Saving Cache"
.bin/zstash save --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./Gemfile.lock" }}-ruby' \
  vendor/bundle

.bin/zstash save --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./Podfile.lock" }}-pods' \
  Pods

.bin/zstash save --local-cache-path $NSC_CACHE_PATH \
  --key '{{ env "BUILDKITE_PIPELINE_NAME" }}/{{ env "BUILDKITE_BRANCH" }}-{{ shasum "./Package.resolved" }}-spm' \
  "${HOME}/Library/Caches/org.swift.swiftpm"
