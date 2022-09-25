require "arxutils_sqlite3"

module Feedlrop
  class Cli
    def self.setup
      token = ENV.fetch("FEEDLY_DEVELOPER_ACCESS_TOKEN", nil)
      user_id = ENV.fetch("FEEDLER_USE_ID", nil)
      env = ENV.fetch("ENV", nil)
      # env ||= "development"
      env ||= "production"

      hash = {
        'db_dir' => Arxutils_Sqlite3::Config::DB_DIR,
        'migrate_dir' => Arxutils_Sqlite3::Config::MIGRATE_DIR,
        'config_dir' => Arxutils_Sqlite3::Config::CONFIG_DIR,
        "dbconfig" => Arxutils_Sqlite3::Config::DBCONFIG_SQLITE3,
        'env' => env,
        'log_fname' => Arxutils_Sqlite3::Config::DATABASELOG,
        'output_dir' => ::Feedlrop::OUTPUT_DIR,
        'pstore_dir' =>  ::Feedlrop::PSTORE_DIR,
      }

      [token, user_id, hash]
    end
  end
end