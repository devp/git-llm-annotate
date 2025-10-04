const CACHE_NAME = 'megajuice-v1';
const urlsToCache = [
    '/megajuice/',
    '/megajuice/index.html',
    '/megajuice/style.css',
    '/megajuice/script.js',
    '/megajuice/manifest.json',
    '/megajuice/data/feed.json',
    '/megajuice/icons/icon-192x192.png',
    '/megajuice/icons/icon-512x512.png',
    'https://unpkg.com/swiper/swiper-bundle.min.css',
    'https://unpkg.com/swiper/swiper-bundle.min.js'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Opened cache');
                return cache.addAll(urlsToCache);
            })
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                if (response) {
                    return response;
                }
                return fetch(event.request).then(
                    response => {
                        if (!response || response.status !== 200 || response.type === 'opaque') {
                            return response;
                        }

                        const responseToCache = response.clone();
                        caches.open(CACHE_NAME)
                            .then(cache => {
                                cache.put(event.request, responseToCache);
                            });
                        return response;
                    }
                );
            })
    );
});

self.addEventListener('activate', event => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});