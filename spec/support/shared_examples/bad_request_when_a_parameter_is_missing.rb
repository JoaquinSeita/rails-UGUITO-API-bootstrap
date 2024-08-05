shared_examples 'bad request when a parameter is missing' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end
end
