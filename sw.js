// BB Calculator — service worker
// Strategy: network-first for the HTML shell (so updates land quickly),
// cache-first for everything else (fast loads, works offline).
const CACHE = 'bb-calc-v2';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './assets/watermark.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;

  // Only handle same-origin GETs
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  // Network-first for navigation / HTML — updates land without waiting for a cache bump
  if (req.mode === 'navigate' || (req.destination === 'document')) {
    e.respondWith(
      fetch(req)
        .then(resp => {
          const copy = resp.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
          return resp;
        })
        .catch(() => caches.match(req).then(r => r || caches.match('./index.html') || caches.match('./')))
    );
    return;
  }

  // Cache-first for everything else
  e.respondWith(
    caches.match(req).then(cached => {
      if (cached) return cached;
      return fetch(req).then(resp => {
        if (resp && resp.status === 200 && resp.type === 'basic') {
          const copy = resp.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        }
        return resp;
      });
    })
  );
});
