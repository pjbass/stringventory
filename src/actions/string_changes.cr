module Stringventory::Actions::StringChanges

  # Method to process actions
  def self.process_action(act : StrVAction, gtr_name = "", str_name = "") : Array(Models::StringChange)
    case act
    when StrVAction::Create

      gtr = Models::Guitar.find_by name: gtr_name

      if gtr

        ret = [gtr]

        pack = Actions::Strings.process_action act, name: str_name, num_packs: 1

        if pack.empty?
          gtr.errors << Granite::Error.new field: :str_name, message: "Strings not found"

        elsif !pack[0].errors.empty?
          gtr.errors << pack[0].errors[0]

        else

          sc = Models::StringChange.create guitar_id: gtr.id, strings_id: pack[0].id, message: msg
          sc.save

          if !sc.errors.empty?
            gtr.errors << sc.errors[0]
          end
        end
      end
    end
  end
end
