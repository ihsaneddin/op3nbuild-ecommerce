namespace :db do
  task :setup_properties => :environment do

  	Property.destroy_all
  	Property.create [
  										{id: 1, identifing_name: "length", display_name: "Length", units: "centimeter,meter", active: true},
  										{id: 2, identifing_name: "width", display_name: "Width", units: "centimeter,meter", active: true},
  										{id: 3, identifing_name: "weight", display_name: "Weight", units: "kilogram", active: true},
  										{id: 4, identifing_name: "height", display_name: "Height", units: "centimeter,meter", active: true},
  									]

  end
end