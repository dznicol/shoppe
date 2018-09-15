module Shoppe

  # The Shoppe::Country model stores countries which can be used for delivery & billing
  # addresses for orders.
  #
  # You can use the Shoppe::CountryImporter to import a pre-defined list of countries
  # into your database. This automatically happens when you run the 'shoppe:setup'
  # rake task.

  class Country < Shoppe::ApplicationRecord

    self.table_name = 'shoppe_countries'

    # All orders which have this country set as their billing country
    has_many :billed_orders, dependent: :restrict_with_exception, class_name: 'Shoppe::Order', foreign_key: 'billing_country_id'

    # All orders which have this country set as their delivery country
    has_many :delivered_orders, dependent: :restrict_with_exception, class_name: 'Shoppe::Order', foreign_key: 'delivery_country_id'

    has_and_belongs_to_many :retailers, :class_name => 'Shoppe::Retailer', join_table: 'shoppe_countries_retailers'

    # All countries ordered by their name asending
    scope :ordered, -> { order(name: :asc) }

    # Validations
    validates :name, presence: true

    US_STATES = {
      'Alabama': 'AL',
      'Alaska': 'AK',
      'American Samoa': 'AS',
      'Arizona': 'AZ',
      'Arkansas': 'AR',
      'California': 'CA',
      'Colorado': 'CO',
      'Connecticut': 'CT',
      'Delaware': 'DE',
      'District Of Columbia': 'DC',
      'Federated States Of Micronesia': 'FM',
      'Florida': 'FL',
      'Georgia': 'GA',
      'Guam': 'GU',
      'Hawaii': 'HI',
      'Idaho': 'ID',
      'Illinois': 'IL',
      'Indiana': 'IN',
      'Iowa': 'IA',
      'Kansas': 'KS',
      'Kentucky': 'KY',
      'Louisiana': 'LA',
      'Maine': 'ME',
      'Marshall Islands': 'MH',
      'Maryland': 'MD',
      'Massachusetts': 'MA',
      'Michigan': 'MI',
      'Minnesota': 'MN',
      'Mississippi': 'MS',
      'Missouri': 'MO',
      'Montana': 'MT',
      'Nebraska': 'NE',
      'Nevada': 'NV',
      'New Hampshire': 'NH',
      'New Jersey': 'NJ',
      'New Mexico': 'NM',
      'New York': 'NY',
      'North Carolina': 'NC',
      'North Dakota': 'ND',
      'Northern Mariana Islands': 'MP',
      'Ohio': 'OH',
      'Oklahoma': 'OK',
      'Oregon': 'OR',
      'Palau': 'PW',
      'Pennsylvania': 'PA',
      'Puerto Rico': 'PR',
      'Rhode Island': 'RI',
      'South Carolina': 'SC',
      'South Dakota': 'SD',
      'Tennessee': 'TN',
      'Texas': 'TX',
      'Utah': 'UT',
      'Vermont': 'VT',
      'Virgin Islands': 'VI',
      'Virginia': 'VA',
      'Washington': 'WA',
      'West Virginia': 'WV',
      'Wisconsin': 'WI',
      'Wyoming': 'WY'
    }

  end
end
