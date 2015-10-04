# -*- coding: utf-8 -*-
require 'arxutils'
require 'arxutils/store'
require 'csv'
require 'pp'
require 'feedlr'
require 'awesome_print'

module Feedlrop
  class Feedlrop
    
    def initialize( token , kind, hs  )
      @oauth_access_token = token
      @dbmgr = Arxutils::Store.init(kind , hs ){ | register_time |
        Dbutil::DbMgr.new( register_time )
      }
      
      @client = Feedlr::Client.new(sandbox: false ,  oauth_access_token: @oauth_access_token)
      @profile = @client.user_profile
      @categories = @client.user_categories
    end

    def get_output_file( ext )
      n = Time.now
      fname = %Q!#{n.year}-#{n.month}-#{n.day}-#{n.hour}-#{n.min}-#{n.sec}.#{ext}!
      File.open( fname , "w")
    end

    def get_all_unread_count
      #p categories
      @categories.each do | x |
        #  f.puts "id=#{x.id.split('/')[-1]}"
        f = true
        if x.class == String
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
      ap @profile
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

    def csv_close
      @csv.close
    end
  end
end
