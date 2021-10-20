require "./enums"
require "../models/*"

# Module to perform actions based around strings
module Stringventory::Actions::Strings

  # Method to process actions
  def self.process_action(act : StrVAction, opts : Hash(Symbol, Int|String)) : Array(Models::Strings)

    ret = [] of Models::Strings

    case act
    when StrVAction::Create
      pack = Models::Strings.new name: opts[:name], num_strings: opts[:num_strs], num_packs: opts[:num_packs]
      pack.save

      ret = [pack]
    when StrVAction::List
      if opts[:name].to_s.empty?
        packs = Models::Strings.all
        ret = packs.to_a if packs
      else
        pack = Models::Strings.find_by name: opts[:name]
        ret = [pack] if pack
      end
    when StrVAction::Update, StrVAction::StringChange

      if act == StrVAction::StringChange
        opts[:num_packs] = -opts[:num_packs].to_i32
      end

      pack = Models::Strings.find_by name: opts[:name]

      if pack
        if pack.num_packs + opts[:num_packs].to_i32 > 0
          pack.num_packs += opts[:num_packs].to_i32
          pack.save
        else
          pack.errors << Granite::Error.new field: :num_packs, message: "The number of packs must be greater than or equal to 0"
        end
        ret = [pack]
      end

    end

    return ret
  end

end
