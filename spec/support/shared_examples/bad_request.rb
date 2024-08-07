shared_examples 'missing parameter bad request' do
  it 'returns status code bad request' do
    expect(response).to have_http_status(:bad_request)
  end

  it 'returns an error message' do
    expect(response_body['error']).to eq(I18n.t('errors.messages.incorrect_parameter'))
  end
end
