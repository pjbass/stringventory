require "sqlite3"
require "granite"
require "granite/adapter/sqlite"

module Stringventory::Models

  # Class representing a string change.
  class StringChange < Granite::Base
    connection con
    table string_changes

    # Primary key for the table. Not used otherwise.
    column id : Int64, primary: true

    # When the string change occured. Defaults to the current time.
    column occurred_on : Time = Time.local

    # Tuning that the guitar is strung to. Defaults to Standard, whatever that
    # may mean for the guitar.
    column tuning : String = "Standard"

    # Optional message regarding a string change (maybe something dealing with
    # pickups or setups, something like that).
    column message : String?

    belongs_to :guitar
    belongs_to :strings

    def to_s

      dt = @occurred_on.as(Time).to_s "%d/%m/%Y"

      msg = ""
      if !@message.nil?
        msg = "\n  #{@message}"
      end

      "Restrung #{guitar.name} with #{strings.name} on #{dt}. Tuned to #{@tuning}.#{msg}"

    end

  end
end
