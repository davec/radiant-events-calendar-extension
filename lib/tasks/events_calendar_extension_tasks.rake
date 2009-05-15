namespace :radiant do
  namespace :extensions do
    namespace :events_calendar do
      
      desc "Runs the migration of the Events Calendar extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          EventsCalendarExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          EventsCalendarExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Events Calendar to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from EventsCalendarExtension"
        Dir[EventsCalendarExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(EventsCalendarExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
