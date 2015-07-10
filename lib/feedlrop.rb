# -*- coding: utf-8 -*-
require "feedlrop/version"

require 'yaml'
require 'csv'
require 'pp'
require 'forwardable'

require 'feedlr'

require 'arxutils'
require 'dbutil_base'
require 'dbutil_base'
require 'dbutil_freedlrop'

module Feedlrop
  class Feedlrop
    extend Forwardable
    
#    def_delegator( :@dbmgr , :add , :db_add)

    def initialize
      @sqlite3yaml = 'config/sqlite3.yaml'
      @databaselog = 'db/database.log'
      
      @oauth_access_token = 'Al_RuRJ7ImEiOiJGZWVkbHkgRGV2ZWxvcGVyIiwiZSI6MTQzODI3NDEzOTc2NSwiaSI6IjA0ZmE3ODczLWE3NjEtNDZkMy05MmRjLTNmNjIzNWRmMDA0ZiIsInAiOjYsInQiOjEsInYiOiJwcm9kdWN0aW9uIiwidyI6IjIwMTMuMTEiLCJ4Ijoic3RhbmRhcmQifQ:feedlydev'

      register_time = Arxutils::Dbutil::DbMgr.init( @sqlite3yaml , @databaselog )
      p "=Feedlrop::Feedlrop.new"
      p "=register_time"
      p register_time
      @dbmgr = Dbutil::DbMgr.new( register_time )
      p "=@dbmgr"
      p @dbmgr
      @client = Feedlr::Client.new(sandbox: false ,  oauth_access_token: @oauth_access_token)
      #p client.api_methods
      @profile = @client.user_profile

      @categories = @client.user_categories
    end

    def get_output_file( ext )
      n = Time.now
      fname = %Q!#{n.year}-#{n.month}-#{n.day}-#{n.hour}-#{n.min}-#{n.sec}.#{ext}!
      File.open( fname , "w")
    end

    def csv_open
      @csv = CSV.new(get_output_file("csv") , {
                       :headers => %w!category_id id count!,
                       :write_headers => true
                     } )
    end

    def csv_add(category_id , id , count)
      @csv << [category_id , id , count ]
    end

    def get_all_unread_count
      #p categories
      @categories.each do | x |
        #  f.puts "id=#{x.id.split('/')[-1]}"
        category_id = x.id.split('/')[-1]
        
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

    def csv_close
      @csv.close
    end
  end
end
