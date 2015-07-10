# -*- coding: utf-8 -*-
require 'forwardable'
require 'pp'

module Feedlrop
  module Dbutil
    class Unreadfeed < ActiveRecord::Base
    end

    class Countdatetime < ActiveRecord::Base
    end

    class DbMgr
      extend Forwardable
      
      def_delegator( :@feedlropmgr , :add, :add)

      def initialize( register_time )
        @feedlropmgr = FeedlropMgr.new( register_time )
      end

    end
    
    class FeedlropMgr
      
      extend Forwardable

      def initialize(register_time)
        @register_time = register_time
        @ct = Countdatetime.create( countdatetime: @register_time )
      end

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

      def find(id)
        Unreadfeed.find(id)
      end
      
    end
  end
end
