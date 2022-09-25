# frozen_string_literal: true

require 'spec_helper'

describe Feedlrop do
  let( :ary ) { Feedlrop::Cli.setup }
  let( :opts ) { {} }

  it 'has a version number' do
    expect(Feedlrop::VERSION).not_to be_nil
  end

  it 'LOCAL_PSTORE' , cmd: :lp do
    token, user_id, hash = ary
    # opts = {}
    # opts["cmd"] = "lp"
    flop = Feedlrop::Feedlrop.new(
      token,
      hash
    )

    expect {
      flop.check_backup
    }.to_not raise_error(StandardError)
  end

  it 'LOCAL_PSTORE_AND_DATA' , cmd: :lpd do
    token, user_id, hash = ary
    # opts = {}
    # opts["cmd"] = "lpd"
    flop = Feedlrop::Feedlrop.new(
      token,
      hash
    )

    expect {
      flop.check_backup
      flop.csv_to_db
    }.to_not raise_error(StandardError)
  end

  it 'REMOTE' , cmd: :r do
    token, user_id, hash = ary
    # opts = {}
    # opts["cmd"] = "r"
    flop = Feedlrop::Feedlrop.new(
      token,
      hash
    )

    expect {
      flop.csv_open(hash['output_dir'])
      ret = flop.all_unread_count
      puts "all_unread_count=#{ret.size}"
      flop.csv_close
    }.to_not raise_error(StandardError)
  end
end
