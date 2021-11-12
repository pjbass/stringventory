module Stringventory::Actions::StringChanges

  # Method to process actions
  def self.process_action(act : Action, gtr_name = "", str_name = "", msg : String? = nil, dt = Time.local, tuning = "Standard") : Array(Models::StringChange)

    ret = [] of Models::StringChange

    case act
    when Action::Create

      gtr = Models::Guitar.find_by name: gtr_name

      if gtr

        pack = Actions::Strings.process_action Action::Update, name: str_name, num_packs: -1

        if pack.empty?
          raise ArgumentError.new "Strings #{str_name} not found"

        elsif !pack[0].errors.empty?
          raise RuntimeError.new pack[0].errors[0].message

        else

          sc = Models::StringChange.create guitar_id: gtr.id, strings_id: pack[0].id, message: msg, occurred_on: dt, tuning: tuning
          sc.save

          ret = [sc]
        end

      else
        raise ArgumentError.new "Guitar #{gtr_name} not found!"
      end

    when Action::List

      if gtr_name.empty? && str_name.empty?
        ret = Models::StringChange.order(:guitar_id).select().to_a
      elsif !gtr_name.empty?
        gtr = Models::Guitar.find_by name: gtr_name

        if !gtr
          raise ArgumentError.new "Guitar #{gtr_name} not found!"
        elsif !gtr.errors.empty?
          raise RuntimeError.new gtr.errors[0].message
        end

        ret = gtr.string_changes.to_a
      else
        pack = Models::Strings.find_by name: str_name

        if !pack
          raise ArgumentError.new "Strings #{str_name} not found!"
        elsif !pack.errors.empty?
          raise RuntimeError.new pack.errors[0].message
        end

        ret = pack.string_changes.to_a
      end

    end

    return ret
  end
end
