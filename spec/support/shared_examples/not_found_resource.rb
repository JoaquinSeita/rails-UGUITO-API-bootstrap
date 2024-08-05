RSpec.shared_examples 'not found resource' do
  it 'responds with 404 status' do
    expect(response).to have_http_status(:not_found)
  end
end
