require "sqlite3"
require "granite"
require "granite/adapter/sqlite"

module Stringventory::Models

  # Class representing a guitar.
  class Guitar < Granite::Base
    connection con
    table guitars

    # Instances where the strings have been changed on the guitar.
    has_many :string_changes, class_name: StringChange

    # Primary key for the table. Not used otherwise.
    column id : Int64, primary: true

    # Name of the guitar. Must be unique
    column name : String

    # Number of strings on the guitar. Defaults to 6
    column num_strings : Int32 = 6

    # Timestamps for the creation and latest update
    timestamps

    validate_uniqueness :name
    validate_not_blank :name
    validate_greater_than :num_strings, 0

    # This should ensure that the number of strings stays reasonable, even
    # with weird Chapman stick type guitars.
    validate_less_than :num_strings, 50

    # To string method that returns a reasonable string representation of the
    # guitar.
    def to_s

      return "#{@name} (#{@num_strings} string)"

    end

  end
end
