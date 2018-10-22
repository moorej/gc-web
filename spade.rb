require 'date'

class Spade
  attr_accessor :id, :name, :img_url, :next_name, :days_down, :days_until

  SPADE_PARTIALS = [
    { :id => 'SEEDLING', :name => 'Seedling', :min_mo => 0, :dur => 1, :next_name => 'Bronze Spade' },
    { :id => 'BRONZE', :name => 'Bronze Spade', :min_mo => 1, :dur => 2, :next_name => 'Silver Spade' },
    { :id => 'SILVER', :name => 'Silver Spade', :min_mo => 3, :dur => 3, :next_name => 'Gold Spade' },
    { :id => 'GOLD', :name => 'Gold Spade', :min_mo => 6, :dur => 3, :next_name => 'Palladium Spade' },
    { :id => 'PALLADIUM', :name => 'Palladium Spade', :min_mo => 9, :dur => 3, :next_name => 'Platinum Spade' },
    { :id => 'PLATINUM', :name => 'Platinum Spade', :min_mo => 12, :dur => 3, :next_name => 'Ruby' },
    { :id => 'RUBY', :name => 'Ruby', :min_mo => 15, :dur => 3, :next_name => 'Emerald' },
    { :id => 'EMERALD', :name => 'Emerald', :min_mo => 18, :dur => 3, :next_name => 'Sapphire' },
    { :id => 'SAPPHIRE', :name => 'Sapphire', :min_mo => 21, :dur => 3, :next_name => 'Diamond' },
    { :id => 'DIAMOND', :name => 'Diamond', :min_mo => 24, :dur => 9999, :next_name => nil }
  ]

  def initialize(date)
    @today = Date.today
    s = get_current_spade_partial(date)

    partial = {
      :img_url    => "images/#{s[:id].downcase}.png",
      :days_down  => (@today - (date >> s[:min_mo])).to_i,
      :days_until => s[:dur] != 9999 ? ((date >> (s[:min_mo] + s[:dur])) - @today).to_i :  -1
    }

    s.merge!(partial)
    s.each {|k,v| instance_variable_set("@#{k}",v)}
  end

  def get_current_spade_partial(hp_date)
    # returns id of users current spade, requires date user entered garden

    # Grab the number of months the users been in the garden
    hp_age_months = (@today.year * 12 + @today.month) - (hp_date.year * 12 + hp_date.month)
    if (hp_date.day > @today.day)
      hp_age_months -= 1
    end
    s = SPADE_PARTIALS.select { |s| (s[:min_mo]..(s[:min_mo] + s[:dur]) - 1) === hp_age_months }
    s[0]
  end
end