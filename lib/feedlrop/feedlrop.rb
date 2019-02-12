# -*- coding: utf-8 -*-
require 'arxutils'
require 'csv'
require 'pp'
require 'feedlr'
require 'awesome_print'
require 'fileutils'

module Feedlrop
  class Feedlrop
    def initialize( token , kind, hs , opts )
      @oauth_access_token = token
      register_time = Arxutils::Dbutil::DbMgr.init( hs["db_dir"], hs["migrate_dir"] , hs["config_dir"], hs["dbconfig"] , hs["env"] , hs["log_fname"] , opts )
      @dbmgr = ::Feedlrop::Dbutil::FeedlropMgr.new( register_time )

      @client = Feedlr::Client.new(sandbox: false ,  oauth_access_token: @oauth_access_token)
      @profile = @client.user_profile
      @categories = @client.user_categories
    end

    # 
    def get_output_file( parent_dir , ext )
      n = Time.now
      fname = %Q!#{n.year}-#{n.month}-#{n.day}-#{n.hour}-#{n.min}-#{n.sec}.#{ext}!
      FileUtils.mkdir_p( parent_dir ) if File.exists?( parent_dir )
		  outfname = File.join( parent_dir , fname )
      File.open( outfname , "w")
    end

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

    def print_user_profile
      pp @profile
    end

    def print_subscription
      option = {:plain => true }
      puts @client.user_subscriptions.size
      @client.user_subscriptions.map{|m|  puts m.id}
      puts "==============="
      @client.user_subscriptions.map{|m|  ap m , option }
    end

    def csv_open( parent_dir )
      @csv = CSV.new(get_output_file( parent_dir , "csv" ) , {
                       :headers => %w!category_id id count!,
                       :write_headers => true
                     } )
    end

    def csv_add(category_id , id , count)
      @csv << [category_id , id , count ]
    end

    def csv_close
      @csv.close
    end
  end
end
