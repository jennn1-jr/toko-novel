String coverProxy(String rawUrl, {int w = 400, int h = 600}) {
  if (rawUrl.isEmpty) return '';
  Uri? u;
  try { u = Uri.parse(rawUrl); } catch (_) {}
  if (u == null || (u.host.isEmpty && !rawUrl.startsWith('http'))) {
    return ''; // url tidak valid
  }
  // kalau sudah https dan dari storage/hosting kamu sendiri, boleh langsung
  final host = u.host;
  final isSafeOwn =
      host.endsWith('firebaseapp.com') ||
      host.endsWith('web.app') ||
      host.endsWith('googleusercontent.com') ||
      host.endsWith('cloudfront.net') ||
      host.endsWith('yourdomain.com'); // ganti kalau punya hosting sendiri

  if (u.scheme == 'https' && isSafeOwn) {
    return rawUrl; // tak perlu proxy
  }

  // Weserv butuh host+path TANPA scheme
  final noScheme = '${u.host}${u.hasPort ? ':${u.port}' : ''}${u.path}${u.hasQuery ? '?${u.query}' : ''}';
  return 'https://images.weserv.nl/?url=$noScheme&w=$w&h=$h&fit=cover&output=webp';
}
