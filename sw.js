const CACHE_NAME = 'mainsail-stocks-v2';

// Clear old caches on install
self.addEventListener('install', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(name => name !== CACHE_NAME).map(name => caches.delete(name))
      );
    })
  );
  self.skipWaiting();
});

// Network-first strategy - always try network first, fall back to cache
self.addEventListener('fetch', event => {
  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim());
});
