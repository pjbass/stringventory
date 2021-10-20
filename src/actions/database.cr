require "./enums"
require "../models/*"

# Module to perform actions directly on the database
module Stringventory::Actions::Database

  # Method to process actions
  def self.process_action(act : StrVAction) : Exception|String|Nil

    case act
    when StrVAction::Create
      begin
        Models::Guitar.migrator.create
        Models::Strings.migrator.create
        "Database successfully created!"
      rescue e
        e
      end
    when StrVAction::Update
      begin
        Models::Guitar.migrator.drop_and_create
        Models::Strings.migrator.drop_and_create
        "Database dropped and recreated!"
      rescue e
        e
      end
    when StrVAction::Delete
      begin
        Models::Guitar.migrator.drop
        Models::Strings.migrator.drop
        "Database dropped!"
      rescue e
        e
      end
    end

  end

end
