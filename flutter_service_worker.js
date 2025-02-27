'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "1ab93e2c54d170fead6845a4462f86d0",
"assets/AssetManifest.bin.json": "eeef8838c256f1ca709758ba5901e87d",
"assets/AssetManifest.json": "40c09e14b012ca26ca3ce8d2d03ad8a8",
"assets/assets/icons/1.1.png": "60b9a699cb16b5051b93daf013d68ab8",
"assets/assets/icons/1.2.png": "368e49bfcc3c173aa2a1ee6c8a7d169b",
"assets/assets/icons/2.1.png": "cc5571b7d3dd3eef5c4e42086317673a",
"assets/assets/icons/2.2.png": "b8de1e00c465eae25aa43527ed13e8e9",
"assets/assets/icons/3.1.png": "fc1760bddef7d9379ac830dd8e106b18",
"assets/assets/icons/3.2.png": "3ce8658569268133e674768efff94197",
"assets/assets/icons/4.1.png": "f72259539c3f054c407ddb52e2958598",
"assets/assets/icons/4.2.png": "b004ef4f5ed343829085e6f20402b1d2",
"assets/assets/icons/ban.png": "587866f261ea2aecb8746e13a2dc96ad",
"assets/assets/icons/bell.png": "0ccdea7c74fcec468ad0a45e0bdace24",
"assets/assets/icons/clock.png": "44c5153c30779b5984f697e6785295af",
"assets/assets/icons/comment.png": "a0c30ecb81e3b27a4c12034300cfbb10",
"assets/assets/icons/comment_white.png": "9bd56b55b9a410ed3359a80409274e70",
"assets/assets/icons/desktop_search.png": "2916dc44c0ddadf6aab588c01f56cb8d",
"assets/assets/icons/dislike.png": "65ec3285539c4025fe5f0779b453732d",
"assets/assets/icons/dislike_black.png": "5c6b8c198a5f76bbff93e023cc580ce8",
"assets/assets/icons/flag.png": "3bd226496d20ed2a489cf1ef6331d5fd",
"assets/assets/icons/forward.png": "bc5ad9fa3db911cc41def4d94dc005c6",
"assets/assets/icons/game.png": "78c9bdd5db6be2fec242b3efdf5833f6",
"assets/assets/icons/history.png": "2efe7b8899318a0f751733f027fce20d",
"assets/assets/icons/like.png": "139b27f28aa17e13ba04b2b9d2b4719e",
"assets/assets/icons/like_black.png": "a106bb2b92faaa60f3f3c179e9038f73",
"assets/assets/icons/like_white.png": "a360edae14f16322a1d67f76799c4ccf",
"assets/assets/icons/movie.png": "4292e3199b7e325a35b7fefabd050df4",
"assets/assets/icons/music.png": "ec04808778223ef52d61ea8cc0d899c6",
"assets/assets/icons/playlist.png": "191fd6912f6b59fcf87ea5e7ee3d1dce",
"assets/assets/icons/recycling-symbol.png": "7c0ca32693a6a70779994d7e4dc75666",
"assets/assets/icons/screen.png": "a8385a6ea800afd1f3673407b4d0422e",
"assets/assets/icons/search.png": "521740a6d006bd5f58a933046126a6e3",
"assets/assets/icons/search_active.png": "9d8ad0c42d683995a5816651bf77a0ea",
"assets/assets/icons/share-arrow.png": "eb31fa520bc51515bb71f36feb4ef1c2",
"assets/assets/icons/share.png": "711c458a7c1810b97d84fcf42e94c9c3",
"assets/assets/icons/share_white.png": "8cf11b9ef9e799c4908f28b76e39e552",
"assets/assets/icons/signal.png": "ad172e59149fdf734d59135cb7269d7f",
"assets/assets/icons/sports.png": "e3a30beb593d39a43489fee0760df8db",
"assets/assets/icons/trending.png": "3935dae63cca0ae1224f13c54e7d5ebd",
"assets/assets/icons/videos.png": "a6d9ed92e65c992eadaefe1bba105057",
"assets/assets/icons/video_upload.png": "fb0a9c4d2501e649de4c4fed330dcf51",
"assets/assets/icons/youtube.png": "8f8bc2286e823d24d028e4c2b7ce754d",
"assets/assets/icons/ytkid.png": "9881e19329126733fe61ef0be06b4c8e",
"assets/assets/icons/ytmusic.png": "9213b7ea7116115e3decfdeb67e67ae1",
"assets/assets/images/about.png": "991ffe46114555f89cecc77cd2584a78",
"assets/assets/images/all-devices-black.png": "a79cad4f1279c20bbef1a494d9ed2eb8",
"assets/assets/images/avatar.jpg": "7b00a78088f3e30ba4ae9b536d5dc028",
"assets/assets/images/brothers.jpg": "10a2104a66f490acf87e2b7a7f278fec",
"assets/assets/images/channel_dark.png": "d15ab8ad0a232af6fb5c69ee6ae32810",
"assets/assets/images/channel_light.png": "299e6def9f743292726dce6f0c4989a3",
"assets/assets/images/Creamy%2520Brown%2520Phone%2520Camera%2520Mockup%2520Motivation%2520Quote%2520Mobile%2520Video%2520(8).png": "665fb5012832871fd5cec3d2764f2e0b",
"assets/assets/images/dbestech.jpg": "0bd01bbe0782c30ee560fe356cb7c69c",
"assets/assets/images/exception.png": "35e9be34b754f85fd544af862a2d960e",
"assets/assets/images/fluter_guys.jpg": "9ace02515fa79ebb1b2f3f8cf01cd003",
"assets/assets/images/home1.png": "070e3f0275835430f3e6d22d4e33302b",
"assets/assets/images/home_dark.png": "917de9893071c252fb89ffb7f7be2b1d",
"assets/assets/images/home_light.png": "e18b9f64da705b2fcb8c58160a2e6f2b",
"assets/assets/images/logo.png": "66208aa9d1e419dc29d0583acee8695a",
"assets/assets/images/mit.jpg": "bd65530496447f33d30f27094cca9a14",
"assets/assets/images/offline.png": "91a6828a896de72a8f68eabb4ff4f3e0",
"assets/assets/images/search1.png": "c40f21e685d7364127fa9c30cb1b6ee2",
"assets/assets/images/search2.png": "d8472503238707cc4d19f401f5a71110",
"assets/assets/images/shimmer.png": "c3f00acc1d487d44e7833913c16521f7",
"assets/assets/images/shimmer2.png": "76ca66113f6e3213a2ef6c1d80103cc4",
"assets/assets/images/tech_brothers.png": "5153a2c41e57de010e39fd1102168b9f",
"assets/assets/images/video1.png": "1954df52c8b509efb067804061e3f17d",
"assets/assets/images/video2.png": "2546d8e05dbac4c9824479c94e8c0733",
"assets/assets/images/video3.png": "f136f9a6743c3d25450b8fffe2768822",
"assets/assets/images/video4.png": "a1e145b99cb73c568f493dd388a5bd30",
"assets/assets/images/yt_logo_dark.png": "63bf76184f29caf950a689c87199d6d2",
"assets/FontManifest.json": "b87b76a280f4318c9fcde4d473053d7e",
"assets/fonts/MaterialIcons-Regular.otf": "81e6d799ecf43ea3bf4dc790b10d4680",
"assets/NOTICES": "ed175a2c41f13f26c6b0a490a97fd2d8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "3699bf13e7cd349a1240ea0a080f1ee8",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "a2eb084b706ab40c90610942d98886ec",
"assets/packages/iconsax/lib/assets/fonts/iconsax.ttf": "071d77779414a409552e0584dcbfd03d",
"assets/packages/youtube_player_iframe/assets/player.html": "dc7a0426386dc6fd0e4187079900aea8",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.ico": "b0849c79fefa344f657899bd8c285a86",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "1d8570cdc27b6075f2b0a82dfce1bd64",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "7f54d36235ae1cbf3a6522c46a22e0b0",
"/": "7f54d36235ae1cbf3a6522c46a22e0b0",
"main.dart.js": "caa10d146f63ed03fe026673c42340e6",
"manifest.json": "9e4e45b2daf0be8fe8f128d86719be2f",
"version.json": "c4a8e04d4258507fb1dac9835670e60b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
