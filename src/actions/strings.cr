require "./enums"
require "../models/*"

# Module to perform actions based around strings
module Stringventory::Actions::Strings

  # Method to process actions
  def self.process_action(act : Action, name = "", num_strs = 6, num_packs = 1) : Array(Models::Strings)

    ret = [] of Models::Strings

    case act
    when Action::Create
      pack = Models::Strings.new name: name, num_strings: num_strs, num_packs: num_packs
      pack.save

      ret = [pack]
    when Action::Delete

      pack = Models::Strings.find_by name: name

      if pack
        pack.destroy
        ret = [pack]
      end

    when Action::List
      if name.empty?
        packs = Models::Strings.all
        ret = packs.to_a if packs
      else
        pack = Models::Strings.where(:name, :like, "%#{name}%").select
        ret = pack if pack
      end
    when Action::Update

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
