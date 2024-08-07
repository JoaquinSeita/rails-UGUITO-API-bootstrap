shared_examples 'bad request' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end
end
