require "sqlite3"
require "granite"
require "granite/adapter/sqlite"

module Stringventory::Models

  # Class representing a set of strings.
  class StringChange < Granite::Base
    connection con
    table string_changes

    # Primary key for the table. Not used otherwise.
    column id : Int64, primary: true

    # Optional message regarding a string change (maybe something dealing with
    # pickups or setups, something like that).
    column message : String?

    belongs_to :guitar
    belongs_to :strings

    timestamps

  end
end
