require 'rabl'
Rabl.configure do |config|
  config.xml_options = { skip_types: true }
  config.escape_all_output = true
  config.replace_nil_values_with_empty_strings = true
end
