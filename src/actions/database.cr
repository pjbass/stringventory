require "./enums"
require "../models/*"

# Module to perform actions directly on the database
module Stringventory::Actions::Database

  # Method to process actions
  def self.process_action(act : StrVAction) : Exception|String|Nil

    begin
      case act
      when StrVAction::Create
          Models::Guitar.migrator.create
          Models::Strings.migrator.create
          Models::StringChange.migrator.create
          "Database successfully created!"
      when StrVAction::Update
        begin
          Models::Guitar.migrator.drop_and_create
          Models::Strings.migrator.drop_and_create
          Models::StringChange.migrator.drop_and_create
          "Database dropped and recreated!"
      when StrVAction::Delete
        begin
          Models::Guitar.migrator.drop
          Models::Strings.migrator.drop
          Models::StringChange.migrator.drop
          "Database dropped!"
      end
    rescue e
      e
    end

  end

end
