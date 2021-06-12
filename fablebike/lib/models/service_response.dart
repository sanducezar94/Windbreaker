class ServiceResponse {
  bool success;
  String message;

  ServiceResponse(this.success, this.message);
}

const SUCCESS_MESSAGE = 'Success';
const CONNECTION_TIMEOUT_MESSAGE = 'Conexiunea nu a putut fi realizata.';
const AUTHENTICATION_ERROR_MESSAGE = 'A aparut o eroare la autentificare.';
const SERVER_ERROR_MESSAGE = 'Cererea a nu a putut fi realizata.';
