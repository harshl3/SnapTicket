/// API Configuration & Constants
/// 
/// This file centralizes the API configuration for SnapTicket.
/// 
/// The real API is the default. Pass `--dart-define=API_BASE_URL=<url>` for
/// release builds (for example the Render URL). Mock data is opt-in only for
/// UI development: `--dart-define=USE_MOCK_API=true`.
/// 
/// Note on Android Emulator networking:
/// - `http://10.0.2.2:5000/api` maps to localhost:5000 on the host machine.
/// - For iOS simulator, use `http://localhost:5000/api`.
/// - For physical devices, use your local machine's LAN IP, e.g. `http://192.168.1.100:5000/api`.
class ApiConstants {
  static const bool useMockApi = bool.fromEnvironment('USE_MOCK_API');

  // Real backend base URL (Configurable)
  // Defaulting to typical Android Emulator bridge to host machine port 5000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Express backend endpoints.
  static const String usersEndpoint = '/users';
  static String userByIdEndpoint(String id) => '/users/$id';

  static const String eventsEndpoint = '/events';
  static String eventByIdEndpoint(String id) => '/events/$id';

  static const String bookingsEndpoint = '/bookings';
  static String userBookingsEndpoint(String userId) => '/bookings/user/$userId';
  static String cancelBookingEndpoint(String bookingId) => '/bookings/$bookingId/cancel';
}
