require "rails_helper"

describe Mutations::CreateProvider, type: :request do
  MUTATION = <<~GRAPHQL
    mutation CreateProvider($firstName: String!, $lastName: String,
                        $neighborhood: String, $city: String!, $state: String!,
                        $email: String!, $contactInfo: String!,
                        $facility: String!, $role: String!,
                        $requests: [String!]!, $description: String!) {
      createProvider(input: {
                              firstName: $firstName, lastName: $lastName,
                              neighborhood: $neighborhood, city: $city, state: $state,
                              email: $email, contactInfo: $contactInfo,
                              facility: $facility, role: $role,
                              requests: $requests, description: $description
                            }) {
        errors
        provider { id, firstName, requests { type, satisfied } }
      }
    }
  GRAPHQL

  it "creates a Provider" do
    expect do
      post '/graphql', params: { query: MUTATION, variables: { firstName: 'bob', lastName: 'smith',
                                                               neighborhood: 'sunset', city: 'sf', state: 'CA',
                                                               email: 'bob@example.com', contactInfo: 'internet',
                                                               facility: 'ucsf', role: 'doctor',
                                                               requests: %w(childcare cleaning), description: 'stuff'
      } }
    end.to change { Provider.count }.by(1)

    json = JSON.parse(response.body)
    expect(json['data']['createProvider']['provider']).to include(
                                                            "firstName" => "bob",
                                                            "requests" => [{ "type" => "childcare", "satisfied" => false },
                                                                           { "type" => "cleaning", "satisfied" => false }]
                                                          )
  end
end