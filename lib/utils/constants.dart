const String kBaseUrl = 'https://minkids.onrender.com'; // Use 10.0.2.2 for Android emulator; change if needed
const String kTokenKey = 'minkids_token';
const String kUserKey = 'minkids_user';

String apiPath(String path) => '$kBaseUrl$path';
