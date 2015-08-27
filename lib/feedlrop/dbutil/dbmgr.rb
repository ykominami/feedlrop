# -*- coding: utf-8 -*-
require 'forwardable'
require 'feedlrop/dbutil/feedlropmgr'

module Feedlrop
  module Dbutil
    class DbMgr
      extend Forwardable
      
      def_delegator( :@feedlropmgr , :add, :add)

      def initialize( register_time )
        @feedlropmgr = FeedlropMgr.new( register_time )
      end
    end
  end
end
