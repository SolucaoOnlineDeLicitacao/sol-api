# @see https://github.com/alexreisner/geocoder#testing-apps-that-use-geocoder
Geocoder.configure(:lookup => :test)

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates'  => [-23.6821604, -46.875482],
      'address'      => 'São Paulo, SP, BR',
      'state'        => 'São Paulo',
      'state_code'   => 'SP',
      'country'      => 'Brasil',
      'country_code' => 'BR'
    }
  ]
)
