require "./enums"
require "../models/*"

# Module to perform actions based around strings
module Stringventory::Actions::Strings

  # Method to process actions
  def self.process_action(act : StrVAction, name = "", num_strs = 6, num_packs = 1) : Array(Models::Strings)

    ret = [] of Models::Strings

    case act
    when StrVAction::Create
      pack = Models::Strings.new name: name, num_strings: num_strs, num_packs: num_packs
      pack.save

      ret = [pack]
    when StrVAction::List
      if name.empty?
        packs = Models::Strings.all
        ret = packs.to_a if packs
      else
        pack = Models::Strings.find_by name: name
        ret = [pack] if pack
      end
    when StrVAction::Update, StrVAction::StringChange

      if act == StrVAction::StringChange
        num_packs = -num_packs
      end

      pack = Models::Strings.find_by name: name

      if pack
        if pack.num_packs + num_packs > 0
          pack.num_packs += num_packs
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
