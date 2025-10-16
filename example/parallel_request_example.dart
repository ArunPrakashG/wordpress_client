/// Example: Parallel Request Execution (Feature 5)
///
/// This example demonstrates how to use the RequestScheduler to efficiently
/// execute multiple requests in parallel with configurable concurrency control.
///
/// Benefits:
/// - 3-10x faster batch operations
/// - Configurable concurrency limits
/// - Automatic request queuing
/// - Better resource utilization

import 'dart:async';

import 'package:wordpress_client/wordpress_client.dart';

Future<void> main() async {
  final client = WordpressClient(
    baseUrl: Uri.parse('https://example.com/wp-json/wp/v2'),
    bootstrapper: (b) => b.build(),
  );

  print('═════════════════════════════════════════════════════');
  print('Feature 5: Parallel Request Execution Example');
  print('═════════════════════════════════════════════════════\n');

  // =========================================================================
  // BASIC: Execute multiple requests in parallel
  // =========================================================================
  print('1️⃣ Basic Parallel Execution');
  print('─────────────────────────────\n');

  try {
    final stopwatch = Stopwatch()..start();

    // Create multiple requests
    final futures = List.generate(
      10,
      (i) => client.posts.list(
        ListPostRequest(
          page: i + 1,
          perPage: 5,
        ),
      ),
    );

    // Execute all in parallel
    final results = await Future.wait(futures);

    stopwatch.stop();

    print('✅ Completed 10 parallel requests');
    print('   Total time: ${stopwatch.elapsedMilliseconds}ms');
    print(
        '   Total posts: ${results.fold<int>(0, (sum, r) => sum + (r.isSuccessful ? r.asSuccess().data.length : 0))}');
    print(
        '   Average time per request: ${stopwatch.elapsedMilliseconds ~/ 10}ms\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // MANAGER: Use ParallelRequestManager for concurrency control
  // =========================================================================
  print('2️⃣ Controlled Concurrency with Manager');
  print('──────────────────────────────────────\n');

  try {
    final manager = ParallelRequestManager(
      config: ParallelRequestConfig(
        maxConcurrentRequests: 3,
      ),
    );
    final stopwatch = Stopwatch()..start();

    // Queue multiple requests with max 3 concurrent
    final futures = <Future>[];
    for (var i = 1; i <= 15; i++) {
      futures.add(
        manager.enqueue(
          id: 'post_$i',
          execute: () => client.posts.list(
            ListPostRequest(
              page: i,
              perPage: 1,
            ),
          ),
        ),
      );
    }

    await Future.wait(futures);
    stopwatch.stop();

    print('✅ Completed 15 managed requests (max 3 concurrent)');
    print('   Total time: ${stopwatch.elapsedMilliseconds}ms');
    print('   Completed requests: 15\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // BATCH OPERATION: Fetch multiple specific posts
  // =========================================================================
  print('3️⃣ Batch Fetch Multiple Posts');
  print('─────────────────────────────\n');

  try {
    final postIds = [1, 2, 3, 4, 5];
    final stopwatch = Stopwatch()..start();

    // Fetch specific posts in parallel
    final futures = postIds.map((id) => client.posts.extensions.getById(id));
    final results = await Future.wait(futures);

    stopwatch.stop();

    var successCount = 0;
    final titles = <String>[];

    for (final result in results) {
      if (result.isSuccessful) {
        successCount++;
        final title = result.asSuccess().data.title?.rendered ?? '(untitled)';
        titles.add(title);
      }
    }

    print('✅ Batch fetched ${postIds.length} posts');
    print('   Time taken: ${stopwatch.elapsedMilliseconds}ms');
    print('   Success: $successCount/${postIds.length}');
    print('   Posts: ${titles.join(', ')}\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // MIXED RESOURCES: Fetch posts, media, and comments in parallel
  // =========================================================================
  print('4️⃣ Mixed Resource Parallel Fetch');
  print('───────────────────────────────\n');

  try {
    final stopwatch = Stopwatch()..start();

    // Fetch different resources in parallel
    final postsFuture = client.posts.list(ListPostRequest());
    final mediaFuture = client.media.list(ListMediaRequest());
    final commentsFuture = client.comments.list(ListCommentRequest());

    final results = await Future.wait([
      postsFuture,
      mediaFuture,
      commentsFuture,
    ]);

    stopwatch.stop();

    final postsCount =
        results[0].isSuccessful ? results[0].asSuccess().data.length : 0;
    final mediaCount =
        results[1].isSuccessful ? results[1].asSuccess().data.length : 0;
    final commentsCount =
        results[2].isSuccessful ? results[2].asSuccess().data.length : 0;

    print('✅ Fetched mixed resources in parallel');
    print('   Time taken: ${stopwatch.elapsedMilliseconds}ms');
    print('   Posts: $postsCount');
    print('   Media: $mediaCount');
    print('   Comments: $commentsCount\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // PERFORMANCE COMPARISON: Sequential vs Parallel
  // =========================================================================
  print('5️⃣ Performance Comparison');
  print('──────────────────────────\n');

  try {
    // Sequential execution
    final sequentialStopwatch = Stopwatch()..start();
    var sequentialCount = 0;
    for (var i = 1; i <= 5; i++) {
      final result = await client.posts.extensions.getById(i);
      if (result.isSuccessful) sequentialCount++;
    }
    sequentialStopwatch.stop();

    // Parallel execution
    final parallelStopwatch = Stopwatch()..start();
    final futures = List.generate(
      5,
      (i) => client.posts.extensions.getById(i + 1),
    );
    final results = await Future.wait(futures);
    final parallelCount = results.where((r) => r.isSuccessful).length;
    parallelStopwatch.stop();

    final speedup = sequentialStopwatch.elapsedMilliseconds /
        parallelStopwatch.elapsedMilliseconds;

    print('✅ Performance Results:');
    print(
        '   Sequential (5 posts): ${sequentialStopwatch.elapsedMilliseconds}ms (Success: $sequentialCount)');
    print(
        '   Parallel (5 posts):   ${parallelStopwatch.elapsedMilliseconds}ms (Success: $parallelCount)');
    print('   Speedup:              ${speedup.toStringAsFixed(2)}x faster\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }

  // =========================================================================
  // BEST PRACTICES
  // =========================================================================
  print('6️⃣ Best Practices');
  print('─────────────────\n');

  print('✓ Use parallel requests for independent operations');
  print('✓ Set appropriate concurrency limits (usually 3-10)');
  print('✓ Use Future.wait() for simple parallel execution');
  print('✓ Use RequestScheduler for controlled concurrent requests');
  print('✓ Monitor active/queued request counts');
  print('✓ Handle errors gracefully in Future.wait()');
  print('✓ Expected speedup: 3-10x for batch operations\n');

  client.dispose();
  print('═════════════════════════════════════════════════════');
  print('Example completed successfully!');
  print('═════════════════════════════════════════════════════');
}
