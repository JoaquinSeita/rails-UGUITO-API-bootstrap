RSpec.shared_examples 'valid object response' do
  it 'responds with the expected attributes' do
    expect(response_body.keys).to all(be_in(expected_keys))
  end

  it_behaves_like 'ok status response'
end
