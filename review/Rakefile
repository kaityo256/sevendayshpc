##
## Don't change this file!!
## Instead, edit 'lib/tasks/mytasks.rake' file.
##

Dir.glob('lib/tasks/*.rake').each do |file|
  load(file)
end

desc "+ list tasks"
task :help do
  sh "rake -T"
end

task(:default).clear
task :default => (ENV['RAKE_DEFAULT'] || :help)
