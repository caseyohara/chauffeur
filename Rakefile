require 'coyote/rake'

task :default => ['build']
multitask :build => ['css:build','js:build']
multitask :watch => ['css:watch','js:watch']

namespace :css do
  coyote do |config|
    config.input = "src/css/app/application.less"
    config.output = "public/css/application.css"
  end
end

namespace :js do
  coyote do |config|
    config.input = "src/js/app/application.coffee"
    config.output = "public/js/application.js"
  end
end

