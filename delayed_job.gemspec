# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.add_dependency   'activesupport', ['>= 3.0', '< 6'] # we've only tested on 4.1 so far
  spec.authors        = ['Tracker Team']
  spec.description    = 'Tracker hacked version to allow for Ordered Delayed Jobs'
  spec.email          = ['tracker@pivotal.io']
  spec.files          = %w(CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md Rakefile delayed_job.gemspec)
  spec.files         += Dir.glob('{contrib,lib,recipes,spec}/**/*')
  spec.homepage       = 'http://github.com/pivotaltracker/delayed_job'
  spec.licenses       = ['MIT']
  spec.name           = 'delayed_job'
  spec.require_paths  = ['lib']
  spec.summary        = 'Database-backed asynchronous priority queue system -- Extracted from Shopify'
  spec.test_files     = Dir.glob('spec/**/*')
  spec.version        = '4.0.4246'
end
