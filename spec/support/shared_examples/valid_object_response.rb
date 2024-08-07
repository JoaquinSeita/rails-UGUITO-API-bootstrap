shared_examples 'valid object response' do
  it 'responds with the expected attributes' do
    expect(expected_keys).to contain_exactly(*response_body.keys)
  end

  it_behaves_like 'ok status response'
end
