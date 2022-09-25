# frozen_string_literal: true

require 'arxutils_sqlite3'
require 'csv'
require 'pp'
require 'feedlr'
require 'awesome_print'
require 'fileutils'
require 'ykxutils'

module Feedlrop
  # Feedlr操作クラス
  class Feedlrop
    attr_reader :categories, :profile

    # 初期化
    def initialize(token, hash)
      # OAuthアクセストークン
      @oauth_access_token = token

      db_dir = hash['db_dir']
      config_dir = hash['config_dir']
      env = hash['env']
      dbconfig = hash['dbconfig']
      @output_dir = hash['output_dir']
      @pstore_dir = hash['pstore_dir']

      dbconfig_path = Arxutils_Sqlite3::Util.make_dbconfig_path(config_dir, dbconfig)
      log_path = Arxutils_Sqlite3::Util.make_log_path(db_dir, dbconfig)
      dbconnect = Arxutils_Sqlite3::Dbutil::Dbconnect.new(
        dbconfig_path,
        env,
        log_path
      )
      register_time = dbconnect.connect
      # register_time = Arxutils::Dbutil::Dbconnect.init( hs["db_dir"], hs["migrate_dir"] , hs["config_dir"], hs["dbconfig"] , hs["env"] , hs["log_fname"] , opts )
      # 保存用DBマネージャ
      # @dbmgr = ::Feedlrop::Dbutil::FeedlropMgr.new(register_time)
      @dbmgr = Dbutil::FeedlropMgr.new(register_time)
      # Feedlrクライアント
      @client = Feedlr::Client.new(sandbox: false, oauth_access_token: @oauth_access_token)
      # ユーザプロファイル
      @profile = @client.user_profile
      # カテゴリ
      @categories = @client.user_categories

      @pstorex = Ykxutils::Pstorex.new(@pstore_dir)
      @pstore_key = ::Feedlrop::PSTORE_KEY
      @pstore_default_value = []
      load_pstore
    end

    # psotreからの取得
    def pstore_fetch(key, default_value)
      @pstorex.fetch(key, default_value)
    end

    # pstore更新
    def pstore_store(key, value)
      @pstorex.store(key, value)
    end

    # DBへ登録
    def dbmgr_add(category_id, url, count)
      @dbmgr.add(category_id, url, count)
    end

    # 出力ファイル取得
    def get_output_file(parent_dir, ext)
      n = Time.now
      fname = %(#{n.year}-#{n.month}-#{n.day}-#{n.hour}-#{n.min}-#{n.sec}.#{ext})
      FileUtils.mkdir_p(parent_dir)
      outfname = File.join(parent_dir, fname)
      File.open(outfname, 'w')
    end

    # 各フィードの未読数を全て取得
    def all_unread_count
      @categories.each do |x|
        if x.instance_of?(Array)
          _err, error_code = x 
          next
        end
        f = true
        if x.instance_of?(String)
          f = false
        else
          category_id = x.id.split('/')[-1]
        end
        next unless f

        en = @client.user_unread_counts({ streamId: x.id })
        next if en.nil?
        en.unreadcounts.each do |y|
          next unless y.id =~ %r{^feed/(.+)}

          url = ::Regexp.last_match(1)
          csv_add(category_id, url, y[:count])
          @dbmgr.add(category_id, url, y[:count])
        end
      end
    end

    # ユーザプロファイルをコンソールへ出力
    def print_user_profile
      pp @profile
    end

    # ユーザサブスクリプションをコンソールへ出力
    def print_subscription
      option = { plain: true }
      # puts @client.user_subscriptions.size
      @client.user_subscriptions.map { |m| puts m.id }
      # puts '==============='
    end

    # 指定ディレクトリに出力準備(CVS形式)
    def csv_open(parent_dir)
      csv_file = get_output_file(parent_dir, 'csv')
      @csv = CSV.new(csv_file,
                     headers: %w[category_id id count],
                     write_headers: true)
    end

    # 出力先にカテゴリID、フィードID、未読数を出力
    def csv_add(category_id, id, count)
      @csv << [category_id, id, count]
    end

    # 出力先クローズ
    def csv_close
      @csv.close
    end

    def load_pstore
      value = pstore_fetch(@pstore_key, @pstore_default_value)

      if value == @pstore_default_value
        new_value = {
          key => {
            profile: @profile,
            categories: @categories
          }
        }
        pstore_store(@pstore_key, new_value)
      end
    end

    def check_backup
      value2 = pstore_fetch(@pstore_key, @pstore_default_value)
      return if value2 == @pstore_default_value

      top = value2[@pstore_key]
      profile = top[:profile]
      categories = top[:categories]
      # p "profile=#{profile}"
      # p "categories.size=#{categories.size}"
      # categories.map{ |x| puts x.label }
    end

    def csv_to_db
      ary = Pathname.new(@output_dir).children.sort_by(&:ctime)
      latest_file = ary.last
      f = latest_file.open
      csv = CSV.new(f,
                    headers: true,
                    write_headers: true)
      csv.each do |row|
        category_id = row['category_id']
        id = row['id']
        count = row['count']
        if !category_id.nil? && !id.nil? && !count.nil?
          dbmgr_add(category_id, id, count)
        else
          p category_id
          p id
          p count
          p '=='
        end
      end
    end
  end
end
