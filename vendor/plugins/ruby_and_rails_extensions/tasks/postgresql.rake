require 'yaml'

namespace :db do
  namespace :postgres do
    def sh_postgresql(config)
      command_text = ''
      command_text << postgresql_command << ' '
      command_text << config['database']         if config['database']
    end

    def postgresql_command
      'psql'
    end

    desc "Start the postgresql shell using the information in the current environments database.yml. [ec]" 
    task :shell do
      system sh_postgresql( YAML.load( open( File.join('config', 'database.yml') ) ) [RAILS_ENV])
    end
  end
end