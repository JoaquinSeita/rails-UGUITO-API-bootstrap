shared_examples 'valid array response' do
  it 'responds with the expected resource amount' do
    expect(response_body.size).to eq(expected.size)
  end

  it 'responds with the expected attributes' do
    expect(response_body.sample.keys).to contain_exactly(*expected_keys)
  end

  it_behaves_like 'ok status response'
end
