require "option_parser"
require "sqlite3"

# `Stringventory` A small command line application designed to keep an
# inventory of guitars and strings.
module Stringventory
  VERSION = "1.1.0"

  # Function to add common options to the add and update subcommands.
  def self.common_opts(parser : OptionParser, res : Resource, opts : Hash(Symbol, Int|String), strings? = true, packs? = true, time? = true, pack_mod = 1)
    r = res.to_s.downcase

    if strings?
      parser.on("-s NUM", "--strings=NUM", "Specify the number of strings") { |n| opts[:num_strs] = n.to_i32 }
    end

    parser.on("-n NAME", "--name=NAME", "Name of the #{r}") { |nm| opts[:name] = nm }

    if res == Resource::Strings && packs? == true
      parser.on("-p NUM", "--num-packs=NUM", "Number of packs to add (default = #{pack_mod * opts[:num_packs].to_i32})") do |pks|
        if pks.to_i32 > 0
          opts[:num_packs] = pack_mod * pks.to_i32
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
  def self.validate_name(opts : Hash(Symbol,Int|String), help_msg : String, act : Action)
    if act != Action::List && opts[:name].to_s.empty?
      STDERR.puts help_msg
      STDERR.puts "Name must be set!"
      exit 3
    end
  end

  # Function to print out the results of processing the specified action.
  def self.print_output(act : Action, res : String, outp : Array(Granite::Base))
    if !outp.empty?
      outp.each do |itm|
        if !itm.errors.empty?
          puts itm.errors[0].message.to_s
        elsif act == Action::List
          puts itm.to_s
        else
          puts "#{act.to_s}d #{itm.to_s}"
        end
      end
    else
      puts "No #{res} found!"
    end
  end

  def self.print_changes(guitars : Array(Models::Guitar), cutoff : Time? = nil)
    if cutoff.nil?

    else
      puts "Work in progress!"
    end
  end

  def self.add_time(parser : OptionParser, res : Resource, opts : Hash(Symbol,Int|String))

    short = "-b DMY"
    long = "--bought=DMY"
    help_msg = "Date the guitar was bought/delivered on."

    if res == Resource::StringChange
      short = "-d DMY"
      long = "--date=DMY"
      help_msg = "Date the string change occurred on."
    end

    help_msg += " Format = d/m/y. Default = now"

    parser.on(short, long, help_msg) { |tm| opts[:date] = tm }
  end

  def self.parse_time(tstr : String, help_msg : String) : Time

    if tstr.empty?
      Time.local
    else
      begin
        Time.parse_local tstr, "%d/%m/%Y"
      rescue e
        STDERR.puts help_msg
        STDERR.puts e.message
        exit 7
      end
    end

  end

end

# For this default, this needs to have 3 /'s on the sqlite protocol portion,
# as the leading / from ENV["HOME"] will get dropped.
db_url = File.join("sqlite3:///", ENV["HOME"], ".local", "share", "stringventory.db")
db_file : String? = nil
db_drop = true
msg : String? = nil
sub_c = Stringventory::Resource::None
comm = Stringventory::Action::None

options = {
  :num_strs => 6,
  :name => "",
  :str_name => "",
  :num_packs => 1,
  :date => "",
  :tuning => "Standard",
}

# Save the help message if it's needed later.
help_message = ""

parser = OptionParser.new do |parser|

  parser.banner = "Usage: stringventory [options] [command] [arguments]"

  parser.on("-d PATH", "--database=PATH", "Specify the database path (default = #{db_url})") { |pth| db_url = pth }

  parser.on("guitars", "Manage guitars") do
    sub_c = Stringventory::Resource::Guitar
    parser.banner = "Usage: stringventory guitars [options] [command] [arguments]"

    parser.on("add", "Add a new guitar") do
      comm = Stringventory::Action::Create
      Stringventory.common_opts(parser, sub_c, options)
      Stringventory.add_time(parser, Stringventory::Resource::Guitar, options)
      help_message = parser.to_s
    end

    # No update method, since it doesn't make _that_ much sense.

    parser.on("remove", "Remove a guitar") do
      comm = Stringventory::Action::Delete
      Stringventory.common_opts(parser, sub_c, options, strings?: false)
      help_message = parser.to_s
    end
    parser.on("list", "List guitars") do
      comm = Stringventory::Action::List
      Stringventory.common_opts(parser, sub_c, options, strings?: false)

      # This one should never fail due to missing name
    end

  end

  parser.on("changes", "Manage string changes") do

    sub_c = Stringventory::Resource::StringChange
    parser.banner = "Usage: stringventory changes [options] [command] [arguments]"

    parser.on("restring", "Restring a guitar") do
      comm = Stringventory::Action::Create

      # Have to set the resource to Guitar so it displays correctly.
      Stringventory.common_opts(parser, Stringventory::Resource::Guitar, options, strings?: false)
      parser.on("-r STRS", "--restring-with=STRS", "Strings to restring the guitar with") { |strs| options[:str_name] = strs }
      parser.on("-m MSG", "--message=MSG", "Optional message to associate with the string change") { |mssg| msg = mssg }
      Stringventory.add_time(parser, Stringventory::Resource::StringChange, options)
      parser.on("-t TNG", "--tuning=TNG", "Tuning that the guitar is strung to. Defaults to Standard") { |tng| options[:tuning] = tng }

      help_message = parser.to_s
    end

    parser.on("list", "List string changes") do
      comm = Stringventory::Action::List
      Stringventory.common_opts(parser, sub_c, options, strings?: false)
      parser.on("-r STRS", "--by-strings=STRS", "Search for changes by string.") { |strs| options[:str_name] = strs }
      help_message = parser.to_s
    end

  end

  parser.on("strings", "Manage strings") do
    sub_c = Stringventory::Resource::Strings
    parser.banner = "Usage: stringventory strings [options] [command] [arguments]"

    help_message = parser.to_s

    parser.on("add", "Add a new string set") do
      comm = Stringventory::Action::Create

      Stringventory.common_opts(parser, sub_c, options)

      help_message = parser.to_s
    end
    parser.on("remove", "Remove a string set") do
      comm = Stringventory::Action::Delete

      Stringventory.common_opts(parser, sub_c, options, strings?: false, packs?: false)

      help_message = parser.to_s
    end
    parser.on("bought", "Add strings to the current stock") do
      comm = Stringventory::Action::Update
      Stringventory.common_opts(parser, sub_c, options, strings?: false)
      help_message = parser.to_s
    end

    parser.on("used", "Remove strings from the current stock outside of a string change") do
      comm = Stringventory::Action::Update

      # Set this as the default, in case no additional amount is provided.
      options[:num_packs] = -1

      Stringventory.common_opts(parser, sub_c, options, strings?: false, pack_mod: -1)
      help_message = parser.to_s
    end

    parser.on("list", "List string packs") do
      comm = Stringventory::Action::List
      Stringventory.common_opts(parser, sub_c, options, strings?: false, packs?: false)
      help_message = parser.to_s
    end

  end

  parser.on("database", "Manage the database") do
    sub_c = Stringventory::Resource::Database
    parser.banner = "Usage: stringventory database [options] [command] [arguments]"

    help_message = parser.to_s

    parser.on("create", "Create the database") do
      comm = Stringventory::Action::Create
      parser.on("-f FNAME", "--file=FNAME", "File to load the database from (default=none)") { |fnm| db_file = fnm }
    end
    parser.on("update", "Drop and recreate the database, with an optional yml file to repopulate it.") do
      comm = Stringventory::Action::Update
      parser.on("-f FNAME", "--file=FNAME", "File to load the database from (default=none)") { |fnm| db_file = fnm }
      db_drop = true
    end
    parser.on("load", "Load items from a file into the database") do
      comm = Stringventory::Action::Update
      parser.on("-f FNAME", "--file=FNAME", "File to load the database entries from (Required)") { |fnm| db_file = fnm }
      db_drop = false
    end
    parser.on("dump", "Dump the database as a yaml file") do
      comm = Stringventory::Action::List
      parser.on("-f FNAME", "--file=FNAME", "File to dump the database to (default=stdout)") { |fnm| db_file = fnm }
    end
    parser.on("drop", "Drop the database and all data") { comm = Stringventory::Action::Delete }

  end

  parser.on("-h", "--help", "Print this help message") do
    puts parser
    exit
  end
end

parser.parse

# Really needed this stuff out of the main module, since granite really needs
# to be required before anything happens with the models, otherwise validations
# don't work
Granite::Connections << Granite::Adapter::Sqlite.new(name: "con", url: db_url)

require "granite"
require "granite/adapter/sqlite"
require "./actions/*"

case sub_c
when Stringventory::Resource::Guitar

  Stringventory.validate_name(options, help_message, comm)

  dt = Stringventory.parse_time options[:date].to_s, help_message

  gtrs = Stringventory::Actions::Guitars.process_action(act: comm,
                                                        name: options[:name].to_s,
                                                        num_strs: options[:num_strs].to_i32,
                                                        str_name: options[:str_name].to_s,
                                                        dt: dt)

  Stringventory.print_output act: comm, res: "guitars", outp: gtrs

when Stringventory::Resource::Strings

  Stringventory.validate_name(options, help_message, comm)

  packs = Stringventory::Actions::Strings.process_action(act: comm,
                                          name: options[:name].to_s,
                                          num_strs: options[:num_strs].to_i32,
                                          num_packs: options[:num_packs].to_i32)

  Stringventory.print_output act: comm, res: "string packs", outp: packs

when Stringventory::Resource::StringChange
  Stringventory.validate_name(options, help_message, comm)
  dt = Stringventory.parse_time options[:date].to_s, help_message

  begin
    chngs = Stringventory::Actions::StringChanges.process_action(act: comm,
                                                                 gtr_name: options[:name].to_s,
                                                                 str_name: options[:str_name].to_s,
                                                                 msg: msg,
                                                                 dt: dt,
                                                                 tuning: options[:tuning].to_s)
  rescue e : Exception
    STDERR.puts e.message
    exit 6
  end

  Stringventory.print_output act: comm, res: "sc", outp: chngs

when Stringventory::Resource::Database
  res = Stringventory::Actions::Database.process_action(comm, db_file, db_drop)

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

