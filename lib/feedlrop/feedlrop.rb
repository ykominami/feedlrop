# -*- coding: utf-8 -*-
require 'arxutils'
require 'csv'
require 'pp'
require 'feedlr'
require 'awesome_print'
require 'fileutils'

module Feedlrop
  # Feedlr操作クラス
  class Feedlrop
    # 初期化
    def initialize( token , kind, hs , opts )
      # OAuthアクセストークン
      @oauth_access_token = token
      register_time = Arxutils::Dbutil::DbMgr.init( hs["db_dir"], hs["migrate_dir"] , hs["config_dir"], hs["dbconfig"] , hs["env"] , hs["log_fname"] , opts )
      # 保存用DBマネージャ
      @dbmgr = ::Feedlrop::Dbutil::FeedlropMgr.new( register_time )
      # Feedlrクライアント
      @client = Feedlr::Client.new(sandbox: false ,  oauth_access_token: @oauth_access_token)
      # ユーザプロファイル
      @profile = @client.user_profile
      # カテゴリ
      @categories = @client.user_categories
    end

    # 出力ファイル取得
    def get_output_file( parent_dir , ext )
      n = Time.now
      fname = %Q!#{n.year}-#{n.month}-#{n.day}-#{n.hour}-#{n.min}-#{n.sec}.#{ext}!
      FileUtils.mkdir_p( parent_dir ) if File.exists?( parent_dir )
		  outfname = File.join( parent_dir , fname )
      File.open( outfname , "w")
    end

    # 各フィードの未読数を全て取得
    def get_all_unread_count
      @categories.each do | x |
        f = true
        if x.class != String
          category_id = x.id.split('/')[-1]
        else
          f = false
        end
        next unless f

        en = @client.user_unread_counts( {:streamId => x.id } )
        en.unreadcounts.each do |y|
          if y.id =~ /^feed\/(.+)/
            url = $1
            csv_add( category_id , url , y[:count] )
            @dbmgr.add(  category_id , url , y[:count] )
          end
        end
      end
    end

    # ユーザプロファイルをコンソールへ出力
    def print_user_profile
      pp @profile
    end

    # ユーザサブスクリプションをコンソールへ出力
    def print_subscription
      option = {:plain => true }
      puts @client.user_subscriptions.size
      @client.user_subscriptions.map{|m|  puts m.id}
      puts "==============="
      @client.user_subscriptions.map{|m|  ap m , option }
    end

    # 指定ディレクトリに出力準備(CVS形式)
    def csv_open( parent_dir )
      @csv = CSV.new(get_output_file( parent_dir , "csv" ) , {
                       :headers => %w!category_id id count!,
                       :write_headers => true
                     } )
    end

    # 出力先にカテゴリID、フィードID、未読数を出力
    def csv_add(category_id , id , count)
      @csv << [category_id , id , count ]
    end

    # 出力先クローズ
    def csv_close
      @csv.close
    end
  end
end