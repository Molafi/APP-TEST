import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/utils/firestore_batch.dart';

void main() {
  group('FirestoreBatch.chunk', () {
    test('empty input produces no chunks', () {
      expect(FirestoreBatch.chunk(<int>[]), isEmpty);
    });

    test('fewer than the limit stays a single chunk', () {
      final items = List<int>.generate(10, (i) => i);
      final chunks = FirestoreBatch.chunk(items);
      expect(chunks, hasLength(1));
      expect(chunks.single, hasLength(10));
    });

    test('exactly the limit stays a single chunk', () {
      final items = List<int>.generate(500, (i) => i);
      final chunks = FirestoreBatch.chunk(items);
      expect(chunks, hasLength(1));
      expect(chunks.single, hasLength(500));
    });

    test('more than 500 items splits into multiple commits', () {
      final items = List<int>.generate(501, (i) => i);
      final chunks = FirestoreBatch.chunk(items);
      expect(chunks, hasLength(2));
      expect(chunks[0], hasLength(500));
      expect(chunks[1], hasLength(1));
    });

    test('1250 items splits into three chunks of <=500 each', () {
      final items = List<int>.generate(1250, (i) => i);
      final chunks = FirestoreBatch.chunk(items);
      expect(chunks, hasLength(3));
      expect(chunks.map((c) => c.length).toList(), [500, 500, 250]);
      // Every chunk stays within the Firestore batch limit.
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(FirestoreBatch.maxOpsPerBatch));
      }
      // No items are lost or duplicated.
      expect(chunks.expand((c) => c).toList(), items);
    });

    test('honours a custom chunk size', () {
      final items = List<int>.generate(5, (i) => i);
      final chunks = FirestoreBatch.chunk(items, 2);
      expect(chunks.map((c) => c.length).toList(), [2, 2, 1]);
    });
  });
}
