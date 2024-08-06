RSpec.shared_examples 'unprocessable entity response' do
  it 'responds with 422 status' do
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
