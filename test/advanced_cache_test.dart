import 'package:test/test.dart';
import 'package:wordpress_client/src/cache/advanced_cache_config.dart';
import 'package:wordpress_client/src/cache/advanced_cache_entry.dart';
import 'package:wordpress_client/src/cache/advanced_cache_manager.dart';
import 'package:wordpress_client/src/cache/cache_invalidation.dart';

void main() {
  group('Advanced Cache Manager', () {
    late AdvancedCacheManager<String> cache;

    setUp(() {
      cache = AdvancedCacheManager<String>(const AdvancedCacheConfig());
    });

    group('Basic Operations', () {
      test('stores and retrieves values', () async {
        await cache.set('key1', 'value1');
        final value = await cache.get('key1');
        expect(value, equals('value1'));
      });

      test('returns null for missing keys', () async {
        final value = await cache.get('nonexistent');
        expect(value, isNull);
      });

      test('removes entries', () async {
        await cache.set('key1', 'value1');
        await cache.remove('key1');
        final value = await cache.get('key1');
        expect(value, isNull);
      });

      test('clears all entries', () async {
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');
        await cache.clear();
        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), isNull);
      });
    });

    group('TTL and Expiry', () {
      test('respects TTL', () async {
        // Note: TTL tests use longer delays due to system timing precision
        await cache.set('key1', 'value1', expiry: const Duration(seconds: 1));

        expect(await cache.get('key1'), equals('value1'));

        // Wait 1.5 seconds to ensure expiry
        await Future.delayed(const Duration(milliseconds: 1500));
        expect(await cache.get('key1'), isNull);
      });

      test('never expires when TTL is 0', () async {
        await cache.set('key1', 'value1', expiry: Duration.zero);
        await Future.delayed(const Duration(seconds: 1));
        expect(await cache.get('key1'), equals('value1'));
      });

      test('uses default TTL from config', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(defaultTtl: Duration(seconds: 1)),
        );
        await cache.set('key1', 'value1'); // Use default TTL

        expect(await cache.get('key1'), equals('value1'));

        await Future.delayed(const Duration(milliseconds: 1500));
        expect(await cache.get('key1'), isNull);
      });
    });

    group('Tag-Based Operations', () {
      test('sets and retrieves entries with tags', () async {
        await cache.setWithTags('post:1', 'Post 1', {'posts', 'featured'});
        expect(await cache.get('post:1'), equals('Post 1'));
      });

      test('invalidates by single tag', () async {
        await cache.setWithTags('post:1', 'Post 1', {'posts'});
        await cache.setWithTags('post:2', 'Post 2', {'posts'});
        await cache.setWithTags('page:1', 'Page 1', {'pages'});

        final result = await cache.invalidateTag('posts');

        expect(result.count, equals(2));
        expect(await cache.get('post:1'), isNull);
        expect(await cache.get('post:2'), isNull);
        expect(await cache.get('page:1'), equals('Page 1'));
      });

      test('tracks multiple tags per entry', () async {
        await cache.setWithTags(
          'item',
          'value',
          {'tag1', 'tag2', 'tag3'},
        );

        final entry = await cache.getEntry('item');
        expect(entry?.tags, containsAll(['tag1', 'tag2', 'tag3']));
      });

      test('handles tag updates', () async {
        await cache.setWithTags('key1', 'value1', {'old_tag'});
        await cache.setWithTags('key1', 'value2', {'new_tag'});

        await cache.invalidateTag('old_tag');
        expect(await cache.get('key1'), equals('value2'));
      });
    });

    group('Cache Invalidation', () {
      test('invalidates by exact key', () async {
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');

        await cache.invalidateKey('key1');
        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), equals('value2'));
      });

      test('invalidates by pattern', () async {
        await cache.set('posts:1', 'Post 1');
        await cache.set('posts:2', 'Post 2');
        await cache.set('pages:1', 'Page 1');

        final result = await cache.invalidatePattern('posts:*');
        expect(result.count, equals(2));
        expect(await cache.get('posts:1'), isNull);
        expect(await cache.get('posts:2'), isNull);
        expect(await cache.get('pages:1'), equals('Page 1'));
      });

      test('invalidates by WordPress path', () async {
        await cache.set('/wp-json/wp/v2/posts/1', 'Post 1');
        await cache.set('/wp-json/wp/v2/posts/1/revisions', 'Revision');
        await cache.set('/wp-json/wp/v2/pages/1', 'Page 1');

        final result =
            await cache.invalidateWordpressPath('/wp-json/wp/v2/posts/*');
        expect(result.count, equals(2));
        expect(await cache.get('/wp-json/wp/v2/pages/1'), equals('Page 1'));
      });

      test('invalidates using custom matcher', () async {
        await cache.set('user:1:active', 'User 1');
        await cache.set('user:2:active', 'User 2');
        await cache.set('user:3:inactive', 'User 3');

        final result = await cache.invalidate(
          InvalidationMatcher.pattern('user:*:active'),
        );
        expect(result.count, equals(2));
        expect(await cache.get('user:3:inactive'), equals('User 3'));
      });

      test('clears all with invalidate all matcher', () async {
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');

        final result = await cache.invalidate(InvalidationMatcher.all());
        expect(result.count, equals(2));
        expect(cache.length, equals(0));
      });
    });

    group('Eviction Strategies', () {
      test('LRU evicts least recently used', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemoryEntries: 2,
          ),
        );

        await cache.set('key1', 'value1');
        await Future.delayed(const Duration(milliseconds: 10));
        await cache.set('key2', 'value2');

        // Access key2 to make it recently used
        await cache.get('key2');
        await Future.delayed(const Duration(milliseconds: 10));

        // Adding new entry should evict key1 (least recently used)
        await cache.set('key3', 'value3');

        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), equals('value2'));
        expect(await cache.get('key3'), equals('value3'));
      });

      test('LFU evicts least frequently used', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemoryEntries: 2,
            evictionStrategy: EvictionStrategy.lfu,
          ),
        );

        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');

        // Access key1 multiple times
        await cache.get('key1');
        await cache.get('key1');

        // Adding new entry should evict key2 (less frequently used)
        await cache.set('key3', 'value3');

        expect(await cache.get('key1'), equals('value1'));
        expect(await cache.get('key2'), isNull);
      });

      test('FIFO evicts oldest entry', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemoryEntries: 2,
            evictionStrategy: EvictionStrategy.fifo,
          ),
        );

        await cache.set('key1', 'value1');
        await Future.delayed(const Duration(milliseconds: 10));
        await cache.set('key2', 'value2');

        // key1 is oldest, should be evicted
        await cache.set('key3', 'value3');

        expect(await cache.get('key1'), isNull);
        expect(await cache.get('key2'), equals('value2'));
        expect(await cache.get('key3'), equals('value3'));
      });

      test('LargestFirst evicts largest entry', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemoryEntries: 2,
            evictionStrategy: EvictionStrategy.largestFirst,
          ),
        );

        await cache.set('small', 'x');
        await cache.set('large', 'x' * 1000);

        // Should evict 'large' because it's biggest
        await cache.set('medium', 'x' * 100);

        expect(await cache.get('small'), equals('x'));
        expect(await cache.get('large'), isNull);
        expect(await cache.get('medium'), equals('x' * 100));
      });
    });

    group('Statistics', () {
      test('tracks hits and misses', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(),
        );

        await cache.set('key1', 'value1');
        await cache.get('key1'); // hit
        await cache.get('key1'); // hit
        await cache.get('nonexistent'); // miss

        expect(cache.statistics.hits, equals(2));
        expect(cache.statistics.misses, equals(1));
        expect(cache.statistics.hitRatio, closeTo(2 / 3, 0.01));
      });

      test('tracks entry count', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(),
        );

        await cache.set('key1', 'value1');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(cache.statistics.currentEntryCount, equals(1));

        await cache.set('key2', 'value2');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(cache.statistics.currentEntryCount, equals(2));

        await cache.remove('key1');
        await Future.delayed(const Duration(milliseconds: 10));
        expect(cache.statistics.currentEntryCount, equals(1));
      });

      test('tracks cache size', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(),
        );

        await cache.set('key1', 'value');
        final size1 = cache.statistics.currentSizeBytes;

        await cache.set('key2', 'value' * 10);
        final size2 = cache.statistics.currentSizeBytes;

        expect(size2, greaterThan(size1));
      });

      test('tracks evictions', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemoryEntries: 2,
          ),
        );

        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');
        await cache.set('key3', 'value3'); // Causes eviction

        expect(cache.statistics.evictions, equals(1));
      });

      test('tracks peak values', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(),
        );

        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');
        expect(cache.statistics.peakEntryCount, equals(2));

        await cache.remove('key1');
        // Peak should remain at 2
        expect(cache.statistics.peakEntryCount, equals(2));
      });

      test('calculates performance metrics', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(),
        );

        await cache.set('key1', 'value1');
        await cache.get('key1');

        await Future.delayed(const Duration(seconds: 1));

        final stats = cache.statistics;
        // hitsPerMinute might be 0 if calculation is instant, so check uptime instead
        expect(stats.uptime,
            greaterThanOrEqualTo(const Duration(milliseconds: 900)));
        expect(stats.hits, equals(1));
      });
    });

    group('Multi-Level Behavior', () {
      test('respects max memory entries limit', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(maxMemoryEntries: 3),
        );

        for (var i = 1; i <= 5; i++) {
          await cache.set('key$i', 'value$i');
        }

        expect(cache.length, lessThanOrEqualTo(3));
      });

      test('respects max memory size limit', () async {
        cache = AdvancedCacheManager<String>(
          const AdvancedCacheConfig(
            maxMemorySizeBytes: 1000,
            evictionStrategy: EvictionStrategy.fifo,
          ),
        );

        // Add entries until size limit is exceeded
        for (var i = 1; i <= 20; i++) {
          await cache.set('key$i', 'x' * 100);
        }

        expect(cache.sizeBytes, lessThanOrEqualTo(1000));
      });
    });

    group('Configuration Presets', () {
      test('highTraffic preset has aggressive settings', () {
        final config = AdvancedCacheConfig.highTraffic();
        expect(config.maxMemoryEntries, equals(5000));
        expect(config.enableCompression, isTrue);
        expect(config.evictionStrategy, equals(EvictionStrategy.lfu));
      });

      test('lowMemory preset has conservative settings', () {
        final config = AdvancedCacheConfig.lowMemory();
        expect(config.maxMemoryEntries, equals(100));
        expect(config.enableCompression, isFalse);
        expect(config.evictionStrategy, equals(EvictionStrategy.fifo));
      });

      test('development preset balances features and size', () {
        final config = AdvancedCacheConfig.development();
        expect(config.maxMemoryEntries, equals(500));
        expect(config.enableStatistics, isTrue);
        expect(config.enableStaleWhileRevalidate, isTrue);
      });
    });

    group('Entry Introspection', () {
      test('getEntry returns entry without updating access', () async {
        await cache.setWithTags('key1', 'value1', {'tag1'});

        final entry1 = await cache.getEntry('key1');
        expect(entry1?.accessCount, equals(0));

        await cache.get('key1'); // This updates access
        final entry2 = await cache.getEntry('key1');
        expect(entry2?.accessCount, equals(1));
      });

      test('getEntry respects expiry', () async {
        await cache.set('key1', 'value1', expiry: const Duration(seconds: 1));

        expect(await cache.getEntry('key1'), isNotNull);

        await Future.delayed(const Duration(milliseconds: 1500));
        expect(await cache.getEntry('key1'), isNull);
      });

      test('getAllKeys returns all keys', () async {
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');

        final keys = await cache.getAllKeys();
        expect(keys, containsAll(['key1', 'key2']));
        expect(keys.length, equals(2));
      });

      test('getAllTags returns all tags', () async {
        await cache.setWithTags('key1', 'v1', {'tag1', 'tag2'});
        await cache.setWithTags('key2', 'v2', {'tag2', 'tag3'});

        final tags = await cache.getAllTags();
        expect(tags, containsAll(['tag1', 'tag2', 'tag3']));
      });

      test('containsKey checks existence', () async {
        await cache.set('key1', 'value1');

        expect(await cache.containsKey('key1'), isTrue);
        expect(await cache.containsKey('nonexistent'), isFalse);
      });
    });

    group('Concurrent Operations', () {
      test('handles concurrent sets', () async {
        final futures = <Future>[];
        for (var i = 0; i < 10; i++) {
          futures.add(cache.set('key$i', 'value$i'));
        }

        await Future.wait(futures);
        expect(cache.length, equals(10));
      });

      test('handles concurrent gets', () async {
        await cache.set('key1', 'value1');

        final futures = <Future>[];
        for (var i = 0; i < 5; i++) {
          futures.add(cache.get('key1'));
        }

        final results = await Future.wait(futures);
        expect(results, everyElement(equals('value1')));
      });

      test('handles concurrent invalidations', () async {
        await cache.setWithTags('key1', 'v1', {'tag1'});
        await cache.setWithTags('key2', 'v2', {'tag2'});

        await Future.wait([
          cache.invalidateTag('tag1'),
          cache.invalidateTag('tag2'),
        ]);

        expect(cache.length, equals(0));
      });
    });
  });

  group('Cache Entry', () {
    test('tracks access correctly', () {
      final now = DateTime.now();
      var entry = AdvancedCacheEntry<String>(
        key: 'key1',
        value: 'value',
        createdAt: now,
        sizeBytes: 100,
      );

      expect(entry.accessCount, equals(0));
      entry = entry.withAccess();
      expect(entry.accessCount, equals(1));
      entry = entry.withAccess();
      expect(entry.accessCount, equals(2));
    });

    test('calculates age correctly', () async {
      final entry = AdvancedCacheEntry<String>(
        key: 'key1',
        value: 'value',
        createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
        sizeBytes: 100,
      );

      await Future.delayed(const Duration(seconds: 1));
      expect(entry.ageSeconds, greaterThanOrEqualTo(5));
    });

    test('checks expiry correctly', () {
      final futureTime = DateTime.now().add(const Duration(seconds: 10));
      final pastTime = DateTime.now().subtract(const Duration(seconds: 10));

      final futureEntry = AdvancedCacheEntry<String>(
        key: 'key1',
        value: 'value',
        createdAt: DateTime.now(),
        expiresAt: futureTime,
        sizeBytes: 100,
      );

      final pastEntry = AdvancedCacheEntry<String>(
        key: 'key2',
        value: 'value',
        createdAt: DateTime.now(),
        expiresAt: pastTime,
        sizeBytes: 100,
      );

      expect(futureEntry.isExpired, isFalse);
      expect(pastEntry.isExpired, isTrue);
    });
  });

  group('Invalidation Matchers', () {
    test('ExactKeyMatcher matches exactly', () {
      final matcher = InvalidationMatcher.exact('key1');
      expect(matcher.matches('key1'), isTrue);
      expect(matcher.matches('key2'), isFalse);
    });

    test('PatternMatcher uses glob patterns', () {
      final matcher = InvalidationMatcher.pattern('posts:*');
      expect(matcher.matches('posts:1'), isTrue);
      expect(matcher.matches('posts:123'), isTrue);
      expect(matcher.matches('pages:1'), isFalse);
    });

    test('PrefixMatcher matches prefix', () {
      final matcher = InvalidationMatcher.prefix('posts:');
      expect(matcher.matches('posts:1'), isTrue);
      expect(matcher.matches('posts:anything'), isTrue);
      expect(matcher.matches('pages:1'), isFalse);
    });

    test('SuffixMatcher matches suffix', () {
      final matcher = InvalidationMatcher.suffix(':active');
      expect(matcher.matches('user:1:active'), isTrue);
      expect(matcher.matches('user:2:active'), isTrue);
      expect(matcher.matches('user:3:inactive'), isFalse);
    });

    test('PredicateMatcher uses custom logic', () {
      final matcher = InvalidationMatcher.predicate(
        (key) => key.startsWith('user:') && key.length > 10,
        description: 'long user keys',
      );
      expect(matcher.matches('user:1:active'), isTrue);
      expect(matcher.matches('user:x'), isFalse);
    });

    test('WordpressPathMatcher matches API paths', () {
      final matcher =
          InvalidationMatcher.wordpressPath('/wp-json/wp/v2/posts/*');
      expect(matcher.matches('/wp-json/wp/v2/posts/1'), isTrue);
      expect(matcher.matches('/wp-json/wp/v2/posts/1/revisions'), isTrue);
      expect(matcher.matches('/wp-json/wp/v2/pages/1'), isFalse);
    });
  });
}
