RSpec.shared_examples 'valid empty array response' do
  it 'responds with an empty array' do
    expect(response_body).to be_empty
  end

  it_behaves_like 'ok status response'
end
