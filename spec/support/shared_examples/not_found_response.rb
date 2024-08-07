shared_examples 'not found response' do
  it 'responds with 404 status' do
    expect(response).to have_http_status(:not_found)
  end
end
