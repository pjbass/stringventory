require "./enums"
require "./strings"
require "../models/*"

# Module to perform actions based around guitars
module Stringventory::Actions::Guitars

  # Method to process actions
  def self.process_action(act : StrVAction, name = "", num_strs = 6, str_name = "", dt = Time.local) : Array(Models::Guitar)

    ret = [] of Models::Guitar

    case act
    when StrVAction::Create

      # Both should be set. Validations on the model itself should handle the
      # permissible values.
      gtr = Models::Guitar.create name: name, num_strings: num_strs, bought_on: dt
      gtr.save

      ret = [gtr]

    when StrVAction::List

      if name.empty?
        gtrs = Models::Guitar.all
        ret = gtrs.to_a if gtrs
      else
        gtr = Models::Guitar.find_by name: name
        ret = [gtr] if gtr
      end

    when StrVAction::Delete

      gtr = Models::Guitar.find_by name: name

      if gtr
        gtr.destroy
        ret = [gtr]
      end

    end

    return ret
  end

end
