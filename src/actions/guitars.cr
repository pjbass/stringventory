require "./enums"
require "./strings"
require "../models/*"

# Module to perform actions based around guitars
module Stringventory::Actions::Guitars

  # Method to process actions
  def self.process_action(act : StrVAction, name = "", num_strs = 6, str_name = "") : Array(Models::Guitar)

    ret = [] of Models::Guitar

    case act
    when StrVAction::Create

      # Both should be set. Validations on the model itself should handle the
      # permissible values.
      gtr = Models::Guitar.create name: name, num_strings: num_strs
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

    when StrVAction::StringChange

      gtr = Models::Guitar.find_by name: name

      if gtr

        ret = [gtr]

        pack = Actions::Strings.process_action act, name: str_name, num_packs: 1

        if pack.empty?
          gtr.errors << Granite::Error.new field: :str_name, message: "Strings not found"

        elsif !pack[0].errors.empty?
          gtr.errors << pack[0].errors[0]

        else

          sc = Models::StringChange.create guitar_id: gtr.id, strings_id: pack[0].id
          sc.save

          if !sc.errors.empty?
            gtr.errors << sc.errors[0]
          end
        end

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
