require 'yaml'

namespace :db do
  namespace :mysql do
    
    def sh_mysql(config)
      command_text = ''
      command_text << mysql_command << ' '
      command_text << "-u#{config['username']} " if config['username']
      command_text << "-p#{config['password']} " if config['password']
      command_text << "-h#{config['host']} "     if config['host']
      command_text << "-P#{config['port']} "     if config['port']
      command_text << config['database']         if config['database']
    end

    def mysql_command
      'mysql'
    end

    desc "Start the mysql shell using the information in the current environments database.yml. [ec]" 
    task :shell do
      system sh_mysql( YAML.load( open( File.join('config', 'database.yml') ) ) [RAILS_ENV])
    end    
  end
end