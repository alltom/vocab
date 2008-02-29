class ActiveRecord::Migration
  class << self

    # Override announce to provide a slightly more useful message including the version we are attemtping to migrate from
    def announce(message)
      text = "#{name}: #{message} from schema version #{ActiveRecord::Migrator.current_version} for #{RAILS_ENV.upcase} mode"
      length = [0, 75 - text.length].max
      write "== %s %s" % [text, "=" * length]
    end
  end
end