require "yaml"
require "./enums"
require "../models/*"

# Module to perform actions directly on the database
module Stringventory::Actions::Database

  # Class used to
  class DataScheme

    include YAML::Serializable

    property guitars : Array(Models::Guitar)
    property strings : Array(Models::Strings)
    property string_changes : Array(Models::StringChange)

    def initialize
      @guitars = Models::Guitar.all.to_a
      @strings = Models::Strings.all.to_a
      @string_changes = Models::StringChange.all.to_a
    end

    def save_all
      @guitars.each do |gtr|
        gtr.save
      end

      @strings.each do |strs|
        strs.save
      end

      @string_changes.each do |str_ch|
        str_ch.save
      end
    end

  end

  # Method to process actions
  def self.process_action(act : StrVAction, db_file : String?) : Exception|String|Nil

    begin
      case act
      when StrVAction::Create
        Models::Guitar.migrator.create
        Models::Strings.migrator.create
        Models::StringChange.migrator.create

        if !db_file.nil?
          data = DataScheme.from_yaml File.read(db_file)
          data.save_all
        end

        "Database successfully created!"
      when StrVAction::Update
        Models::Guitar.migrator.drop_and_create
        Models::Strings.migrator.drop_and_create
        Models::StringChange.migrator.drop_and_create

        if !db_file.nil?
          data = DataScheme.from_yaml File.read(db_file)

          data.save_all

        end

        "Database dropped and recreated!"
      when StrVAction::Delete
        Models::Guitar.migrator.drop
        Models::Strings.migrator.drop
        Models::StringChange.migrator.drop
        "Database dropped!"
      when StrVAction::List
        ret = DataScheme.new().to_yaml
        if !db_file.nil?
          File.write db_file, ret
          "Database written to #{db_file}"
        else
          ret
        end
      end
    rescue e
      e
    end

  end

end
