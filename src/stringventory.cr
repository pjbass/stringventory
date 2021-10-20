require "option_parser"
require "sqlite3"

# `Stringventory` A small command line application designed to keep an
# inventory of guitars and strings.
module Stringventory
  VERSION = "0.1.0"

  # Function to add common options to the add and update subcommands.
  def self.common_opts(parser : OptionParser, res : StrVResource, opts : Hash(Symbol, Int|String), strings = true, packs = true)
    r = res.to_s.downcase

    if strings
      parser.on("-s NUM", "--strings=NUM", "Specify the number of strings") { |n| opts[:num_strs] = n.to_i32 }
    end

    parser.on("-n NAME", "--name=NAME", "Name of the #{r}") { |nm| opts[:name] = nm }

    if res == StrVResource::Strings && packs == true
      parser.on("-p NUM", "--num-packs=NUM", "Number of packs to add (default = #{opts[:num_packs]})") do |pks|
        if pks.to_i32 > 0
          opts[:num_packs] = pks.to_i32
        else
          STDERR.puts parser
          STDERR.puts "Number of strings cannot be 0 or negative!"
          exit 4
        end
      end
    end

  end

  # Function to validate the name field and ensure that it is not empty. Displays
  # help_msg and exits if validation fails.
  def self.validate_name(opts : Hash(Symbol,Int|String), help_msg : String, act : StrVAction)
    if act != StrVAction::List && opts[:name].to_s.empty?
      STDERR.puts help_msg
      STDERR.puts "Name must be set!"
      exit 3
    end
  end

  # Function to print out the results of processing the specified action.
  def self.print_output(act : StrVAction, res : String, outp : Array(Granite::Base))
    if !outp.empty?
      outp.each do |itm|
        if act == StrVAction::List
          puts itm.to_yaml
        else
          if itm.errors.empty?
            puts "#{act.to_s}d #{itm.to_s}"
          else
            puts itm.errors[0].message.to_s
          end
        end
      end
    else
      puts "No #{res} found!"
    end
  end

  # For this default, this needs to have 3 /'s on the sqlite protocol portion,
  # as the leading / from ENV["HOME"] will get dropped.
  db_url = File.join("sqlite3:///", ENV["HOME"], ".local", "share", "stringventory.db")
  sub_c = StrVResource::None
  comm = StrVAction::None

  options = {
    :num_strs => 6,
    :name => "",
    :str_name => "",
    :num_packs => 1,
  }

  # Save the help message if it's needed later.
  help_message = ""

  parser = OptionParser.new do |parser|

    parser.banner = "Usage: stringventory [options] [command] [arguments]"

    parser.on("-d PATH", "--database=PATH", "Specify the database path (default = #{db_url})") { |pth| db_url = pth }

    parser.on("guitars", "Manage guitars") do
      sub_c = StrVResource::Guitar
      parser.banner = "Usage: stringventory guitars [options] [command] [arguments]"

      parser.on("add", "Add a new guitar") do
        comm = StrVAction::Create
        common_opts(parser, sub_c, options)
        help_message = parser.to_s
      end

      # No update method, since it doesn't make _that_ much sense.

      parser.on("restring", "Restring a guitar") do
        comm = StrVAction::StringChange
        common_opts(parser, sub_c, options, strings: false)
        parser.on("-r STRS", "--restring-with=STRS", "Strings to restring the guitar with") { |strs| options[:str_name] = strs }
        help_message = parser.to_s
      end
      parser.on("remove", "Remove a guitar") do
        comm = StrVAction::Delete
        common_opts(parser, sub_c, options, strings: false)
        help_message = parser.to_s
      end
      parser.on("list", "List guitars") do
        comm = StrVAction::List
        common_opts(parser, sub_c, options, strings: false)

        # This one should never fail due to missing name
      end

    end

    parser.on("strings", "Manage strings") do
      sub_c = StrVResource::Strings
      parser.banner = "Usage: stringventory strings [options] [command] [arguments]"

      help_message = parser.to_s

      parser.on("add", "Add a new string set") do
        comm = StrVAction::Create

        common_opts(parser, sub_c, options)

        help_message = parser.to_s
      end
      parser.on("remove", "Remove a string set") do
        comm = StrVAction::Delete

        common_opts(parser, sub_c, options, strings: false, packs: false)

        help_message = parser.to_s
      end
      parser.on("bought", "Add strings to the current stock") do
        comm = StrVAction::Update
        common_opts(parser, sub_c, options, strings: false)
        help_message = parser.to_s
      end

      parser.on("used", "Remove strings from the current stock outside of a string change") do
        comm = StrVAction::StringChange
        common_opts(parser, sub_c, options, strings: false)
        help_message = parser.to_s
      end

      parser.on("list", "List string packs") do
        comm = StrVAction::List
        common_opts(parser, sub_c, options, strings: false, packs: false)
        help_message = parser.to_s
      end

    end

    parser.on("database", "Manage the database") do
      sub_c = StrVResource::Database
      parser.banner = "Usage: stringventory database [options] [command] [arguments]"

      help_message = parser.to_s

      parser.on("create", "Create the database") { comm = StrVAction::Create }
      parser.on("update", "Drop and recreate the database") { comm = StrVAction::Update }
      parser.on("drop", "Drop the database and all data") { comm = StrVAction::Delete }

    end

    parser.on("-h", "--help") do
      puts parser
      exit
    end
  end

  parser.parse

  Granite::Connections << Granite::Adapter::Sqlite.new(name: "con", url: db_url)

  case sub_c
  when StrVResource::Guitar

    validate_name(options, help_message, comm)

    gtrs = Actions::Guitars.process_action(act: comm, opts: options)

    print_output act: comm, res: "guitars", outp: gtrs

  when StrVResource::Strings

    validate_name(options, help_message, comm)

    packs = Actions::Strings.process_action(act: comm, opts: options)

    print_output act: comm, res: "string packs", outp: packs

  when StrVResource::Database
    res = Actions::Database.process_action(comm)

    case res
    when String
      puts res
    when Exception
      STDERR.puts res.message
      exit 2
    when Nil
      STDERR.puts "Action not recognized!"
      exit 5
    end

  else
    STDERR.puts parser
    exit 1
  end

end

require "granite"
require "granite/adapter/sqlite"
require "./actions/*"
