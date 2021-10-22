require "yaml"
require "./enums"
require "../models/*"

# Module to perform actions directly on the database
module Stringventory::Actions::Database

  # Class used to
  class DataScheme

    include YAML::Serializable

    property guitars = [] of Models::Guitar
    property strings = [] of Models::Strings
    property string_changes = [] of Models::StringChange

    def initialize
      @guitars = Models::Guitar.all.to_a
      @strings = Models::Strings.all.to_a
      @string_changes = Models::StringChange.all.to_a
    end

    def save_all

      @guitars.each do |gtr|
        gtr.save

        if !gtr.errors.empty?
          raise gtr.errors[0].message.to_s
        end

      end

      @strings.each do |strs|
        strs.save
        if !strs.errors.empty?
          raise strs.errors[0].message.to_s
        end
      end

      @string_changes.each do |str_ch|
        str_ch.save
        if !str_ch.errors.empty?
          raise str_ch.errors[0].message.to_s
        end
      end
    end

  end

  # Method to process actions
  def self.process_action(act : StrVAction, db_file : String?, db_drop = true) : Exception|String|Nil

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
        if db_drop
          Models::Guitar.migrator.drop_and_create
          Models::Strings.migrator.drop_and_create
          Models::StringChange.migrator.drop_and_create

          if !db_file.nil?
            data = DataScheme.from_yaml File.read(db_file)

            data.save_all

          end

          "Database dropped and recreated!"
        else

          if db_file.nil?
            raise Exception.new message: "No file provided to load from"
          end

          data = DataScheme.from_yaml File.read(db_file)
          data.save_all

          "Data loaded successfully"

        end

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
