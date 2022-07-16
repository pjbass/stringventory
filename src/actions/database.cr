require "yaml"
require "./enums"
require "../models/*"

# Module to perform actions directly on the database
module Stringventory::Actions::Database

  # Class used to allow serialization of data to and from yaml.
  class DataScheme

    include YAML::Serializable

    property guitars = [] of Models::Guitar
    property strings = [] of Models::Strings
    property string_changes = [] of Models::StringChange

    # Get all of the data in the database as arrays.
    def initialize
      @guitars = Models::Guitar.all.to_a
      @strings = Models::Strings.all.to_a
      @string_changes = Models::StringChange.all.to_a
    end

    # Save all of the data in the class into the database. This is typically
    # called with a yaml file to save the values in it into the database
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
  def self.process_action(act : Action, db_file : String?, db_drop = true) : Exception|String|Nil

    begin
      case act
      when Action::Create

        # Create the database by using the migrator to create the tables
        # directly from the models
        Models::Guitar.migrator.create
        Models::Strings.migrator.create
        Models::StringChange.migrator.create

        # Optionally load new data into the initialized database.
        if !db_file.nil?
          data = DataScheme.from_yaml File.read(db_file)
          data.save_all
        end

        "Database successfully created!"
      when Action::Update

        # Drop the database before recreating it. Optionally load in data from
        # a yaml file.
        if db_drop
          Models::Guitar.migrator.drop_and_create
          Models::Strings.migrator.drop_and_create
          Models::StringChange.migrator.drop_and_create

          if !db_file.nil?
            data = DataScheme.from_yaml File.read(db_file)

            data.save_all

          end

          "Database dropped and recreated!"
        # Only load data, do _not_ drop the database.
        else

          if db_file.nil?
            raise Exception.new message: "No file provided to load from"
          end

          data = DataScheme.from_yaml File.read(db_file)
          data.save_all

          "Data loaded successfully"

        end

      when Action::Delete

        # Delete everything from the database.
        Models::Guitar.migrator.drop
        Models::Strings.migrator.drop
        Models::StringChange.migrator.drop
        "Database dropped!"

      when Action::List

        # Return everything in the database as yaml. If a file is
        # specified, write the output to it. If not, return it to the caller.
        ret = DataScheme.new().to_yaml
        if !db_file.nil?
          File.write db_file, ret
          "Database written to #{db_file}"
        else
          ret
        end
      end
    rescue e
      # Return any errors to the caller for handling.
      e
    end

  end

end
