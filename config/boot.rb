require 'rubygems'
<<<<<<< HEAD
require 'yaml'
require 'htmlentities'

YAML::ENGINE.yamler = 'syck'
=======
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
