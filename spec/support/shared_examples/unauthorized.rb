shared_examples 'unauthorized' do
  it 'responses with unauthorized error' do
    expect(response.body).to eq 'Tienes que iniciar sesión o registrarte para poder continuar.'
  end

  it 'responds with 401 status' do
    expect(response).to have_http_status(:unauthorized)
  end
end
