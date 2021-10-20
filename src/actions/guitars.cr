require "./enums"
require "../models/*"

# Module to perform actions based around guitars
module Stringventory::Actions::Guitars

  # Method to process actions
  def self.process_action(act : StrVAction, opts : Hash(Symbol, Int|String)) : Array(Models::Guitar)

    ret = [] of Models::Guitar

    case act
    when StrVAction::Create
      gtr = Models::Guitar.new name: opts[:name], num_strings: opts[:num_strs]
      gtr.save

      ret = [gtr]

    when StrVAction::List

      if opts[:name].to_s.empty?
        gtrs = Models::Guitar.all
        ret = gtrs.to_a if gtrs
      else
        gtr = Models::Guitar.find_by name: opts[:name]
        ret = [gtr] if gtr
      end

    when StrVAction::Delete

      gtr = Models::Guitar.find_by name: opts[:name]

      if gtr
        gtr.destroy
        ret = [gtr]
      end

    else
      puts "guitar subcommand #{act.to_s}: name=#{opts[:name]}, num_str=#{opts[:num_strs]}, strings=#{opts[:str_name]}"
    end

    return ret
  end

end
