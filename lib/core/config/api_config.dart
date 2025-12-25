import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration for NestJS Backend
class ApiConfig {
  // Load backend URLs from environment variables
  static String get localUrl =>
      dotenv.get('API_URL_LOCAL', fallback: 'http://192.168.10.46:3000/api');
  static String get devUrl =>
      dotenv.get('API_URL_DEV', fallback: 'https://dev-api.petconnect.com/api');
  static String get prodUrl =>
      dotenv.get('API_URL_PROD', fallback: 'https://api.petconnect.com/api');

  // Current environment from .env
  static Environment get environment {
    final envString =
        dotenv.get('ENVIRONMENT', fallback: 'local').toLowerCase();
    switch (envString) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'production':
      case 'prod':
        return Environment.production;
      case 'local':
      default:
        return Environment.local;
    }
  }

  // Get the appropriate base URL based on environment
  static String get baseUrl {
    switch (environment) {
      case Environment.local:
        return localUrl;
      case Environment.development:
        return devUrl;
      case Environment.production:
        return prodUrl;
    }
  }

  // API Endpoints
  static const String users = '/users';
  static const String pets = '/pets';
  static const String matches = '/matches';
  static const String swipes = '/swipes';

  // Timeouts from environment or defaults
  static Duration get connectionTimeout => Duration(
        seconds: int.tryParse(dotenv.get('API_TIMEOUT', fallback: '30')) ?? 30,
      );

  static Duration get receiveTimeout => Duration(
        seconds: int.tryParse(dotenv.get('API_TIMEOUT', fallback: '30')) ?? 30,
      );
}

enum Environment {
  local,
  development,
  production,
}
