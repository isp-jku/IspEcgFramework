# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.0.0-beta] - 2017-05-15
### Added
- Cache and FileCache classes to store and retrieve already processed data more efficiently
- Processor abstract class to add featureSet processing capabilities
- Settings class to define library wide settings
- Configuration class as a singelton to hold library wide configuration
- ValidationHelper classes 

### Changed
- extractFeature renamed to extractFeatureSet in IspEcgFramework.data.Data
- extractFeatureSet return type changed from any to an instance of DataFeatureSet

## [1.0.0-beta] - 2017-03-17
- Initial release
