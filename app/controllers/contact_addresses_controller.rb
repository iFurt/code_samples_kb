class ContactAddressesController < ApplicationController
  def states
    states = StatesQuery.new(State.all, params).execute
    render json: states, each_serializer: AddressSelect2Serializer, root: false
  end

  def cities
    cities = CitiesQuery.new(City.all, params).execute
    render json: cities, each_serializer: CitySelect2Serializer, root: false
  end
end
