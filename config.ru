#!/usr/bin/env rackup

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Lint
use Rack::Static, urls: [''], root: 'public', index: 'index.html'
run lambda{|env| }
