# -*- coding: utf-8 -*-
require 'active_record'
require 'pp'

module Feedlrop
  # DB操作用ユーティリティモジュール
  module Dbutil
    # Feedlrに関する情報用DB操作クラス
    class FeedlropMgr
      # 初期化
      def initialize(register_time)
        @register_time = register_time
        @ct = Countdatetime.create( countdatetime: @register_time )
      end

      # 指定フィードの未読情報登録
      def add( category, url , unread_count )
        begin
          uf = Unreadfeed.create( time_id: @ct.id , category: category , url: url , unread_count: unread_count , start_datetime: @register_time )
        rescue => ex
          p ex.class
          p ex.message
          pp ex.backtrace
        end

        uf
      end

      # IDで指定したフィードの未読情報取得
      def find(id)
        Unreadfeed.find(id)
      end
    end
  end
end
