# frozen_string_literal: true

require 'arxutils_sqlite3'
require_relative 'dbacrecord'
require_relative 'feedlrop/version'
require_relative 'feedlrop/feedlrop'
require_relative 'feedlrop/dbutil'
require_relative 'feedlrop/cli'

# Feedlr操作用モジュール
module Feedlrop
  OUTPUT_DIR = "output"
  # PSTORE_DIR = "pstore"
  PSTORE_DIR = "pstore_2"
  PSTORE_KEY = :TOP
end
