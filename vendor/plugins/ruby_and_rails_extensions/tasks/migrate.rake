namespace :db do
  def interesting_tables
    ActiveRecord::Base.connection.tables.sort.reject! do |tbl|
      ['schema_info', 'sessions', 'public_exceptions'].include?(tbl)
    end
  end

  desc "Backup all database data tables to RAILS_ROOT/db/backup in yaml format. [ec]"
  task :backup => :environment do 
    puts "Starting database backup in #{RAILS_ENV} mode."
    dir = RAILS_ROOT + '/db/backup'
    FileUtils.mkdir_p(dir)
    FileUtils.chdir(dir)

    interesting_tables.each do |table_name|
      klass = table_name.classify.constantize
      puts "Backing up #{table_name}..."
      File.open("#{table_name}.yml", 'w+') { |f| YAML.dump klass.find(:all).collect(&:attributes), f }      
    end
  end

  desc "Restore all database data tables from RAILS_ROOT/db/backup to the database. [ec]"
  task :restore => [:environment, 'db:schema:load'] do 
    puts "Starting database restore in #{RAILS_ENV} mode."
    dir = RAILS_ROOT + '/db/backup'
    FileUtils.mkdir_p(dir)
    FileUtils.chdir(dir)

    interesting_tables.each do |table_name|
      klass = table_name.classify.constantize
      ActiveRecord::Base.transaction do     
        puts "Loading #{table_name} into the database..."
        YAML.load_file("#{table_name}.yml").each do |fixture|
          ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{fixture.keys.join(",")}) VALUES (#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
        end        
      end
    end
  end
  
  desc "Returns the current schema version [ec]"
  task :version => :environment do
    puts "Schema version for #{RAILS_ENV} mode: " + ActiveRecord::Migrator.current_version.to_s
  end
  
  desc "Drop and recreate all tables followed by a running of all migrations. [ec]" 
  task :rebuild => :environment do
    return unless %w[development test staging].include?(RAILS_ENV)
    ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }
    Rake::Task['db:migrate'].invoke
  end
  
  desc "Load and run validation against all records for each discovered ActiveRecord model type in database. [ec]"
  task :validate => :environment do
    puts "-- records - model --"
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    Object.subclasses_of(ActiveRecord::Base).select { |c| c.base_class == c}.sort_by(&:name).each do |klass|
      begin
        total = klass.count
        printf "%10d - %s\n", total, klass.name
        puts "Looking up records for #{klass.name}"
        chunk_size = 1000
        (total / chunk_size + 1).times do |i|
          chunk = klass.find(:all, :offset => (i * chunk_size), :limit => chunk_size)
          chunk.reject(&:valid?).each do |record|
            puts "#{record.class}: id=#{record.id}"
            puts record.errors.full_messages
            puts
          end rescue nil
        end
      rescue Exception => ex
        puts "Something blew up!  I hear it was the fault of #{ex}"
      end
    end
  end
  
  namespace :migrate do
    desc "Migrate down one version [ec]"
    task :down => :environment do
      current_version = current_schema_version
      if current_version < 2
        puts "Cannot migrate down for #{RAILS_ENV} mode!  Schema is currently at version #{current_version}."
      else
        puts "Schema is currently at version #{current_version}, attempting migration down to version #{current_version - 1} for #{RAILS_ENV} mode."
        ActiveRecord::Migrator.migrate("db/migrate/", current_version - 1)
        Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
    end
  
    desc "Migrate up one version [ec]"
    task :up => :environment do
      current_version = current_schema_version
      puts "Schema is currently at version #{current_version}, attempting migration to version #{current_version + 1} for #{RAILS_ENV} mode."
      ActiveRecord::Migrator.migrate("db/migrate/", current_version + 1)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    
    desc "Test Migration [ec]"
    task :test_new_migration => [:environment, :up, :down]
    
    def current_schema_version
      begin
        return ActiveRecord::Migrator.current_version.to_i
      rescue
        return 0
      end
    end
    
  end
end

task :mu => 'db:migrate:up' 
task :md => 'db:migrate:down'