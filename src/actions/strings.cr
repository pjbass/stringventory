require "./enums"
require "../models/*"

# Module to perform actions based around strings
module Stringventory::Actions::Strings

  # Method to process actions
  def self.process_action(act : Action, name = "", num_strs = 6, num_packs = 1) : Array(Models::Strings)

    ret = [] of Models::Strings

    case act
    when Action::Create

      # Create a new string pack in the database. This is used when adding
      # strings for the first time, not for adding to the number of packs.
      pack = Models::Strings.new name: name, num_strings: num_strs, num_packs: num_packs
      pack.save

      ret = [pack]
    when Action::Delete

      # Delete a string set from the database. Note that this is deleting the
      # listing for the strings, _not_ decrementing the pack count.
      pack = Models::Strings.find_by name: name

      if pack
        pack.destroy
        ret = [pack]
      end

    when Action::List

      # List all string packs or find them by name.
      if name.empty?
        packs = Models::Strings.all
        ret = packs.to_a if packs
      else
        pack = Models::Strings.where(:name, :like, "%#{name}%").select
        ret = pack if pack
      end
    when Action::Update

      # Increment (or decrement, if num_packs is negative) the number of packs
      # of strings by the amount given in num_packs.
      pack = Models::Strings.find_by name: name

      if pack
        pack.num_packs += num_packs
        pack.save
        ret = [pack]
      end

    end

    return ret
  end

end
