require "sqlite3"
require "granite"
require "granite/adapter/sqlite"

module Stringventory::Models

  # Class representing a set of strings.
  class Strings < Granite::Base
    connection con
    table strings

    # Instances where the strings have been used in a string change.
    has_many :string_changes, class_name: StringChange

    # Primary key for the table. Not used otherwise.
    column id : Int64, primary: true

    # Name of the string pack. Must be unique.
    column name : String

    # Number of strings per pack.
    column num_strings : Int32 = 6

    # Number of packs currently in stock.
    column num_packs : Int32 = 0

    # Timestamps for the creation and latest update
    timestamps

    validate_uniqueness :name
    validate_not_blank :name
    validate_greater_than :num_strings, 0

    # This should ensure that the number of strings stays reasonable, even
    # with weird Chapman stick type guitars.
    validate_less_than :num_strings, 50

    # Can have 0 packs, but not a negative number.
    validate_greater_than :num_packs, 0, true

    # Method to provide a reasonable string representation for the string pack.
    def to_s

      return "#{@name} (#{@num_strings} strings): #{@num_packs} packs"

    end

  end
end
