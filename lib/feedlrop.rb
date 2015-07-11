# -*- coding: utf-8 -*-
require "feedlrop/version"

require 'yaml'
require 'csv'
require 'pp'
require 'forwardable'

require 'feedlr'

require 'arxutils'
require 'dbutil_base'
require 'dbutil_freedlrop'

module Feedlrop
  class Feedlrop
    extend Forwardable
    
    def initialize( db_dir , migrate_dir , config_dir, dbconfig , log_fname )
      
      @oauth_access_token = 'Al_RuRJ7ImEiOiJGZWVkbHkgRGV2ZWxvcGVyIiwiZSI6MTQzODI3NDEzOTc2NSwiaSI6IjA0ZmE3ODczLWE3NjEtNDZkMy05MmRjLTNmNjIzNWRmMDA0ZiIsInAiOjYsInQiOjEsInYiOiJwcm9kdWN0aW9uIiwidyI6IjIwMTMuMTEiLCJ4Ijoic3RhbmRhcmQifQ:feedlydev'

      dbinit = Dbinit.new( db_dir , migrate_dir , config_dir, dbconfig , log_fname )
      register_time = Arxutils::Dbutil::DbMgr.init( dbinit )

      @dbmgr = Dbutil::DbMgr.new( register_time )
      @client = Feedlr::Client.new(sandbox: false ,  oauth_access_token: @oauth_access_token)
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
