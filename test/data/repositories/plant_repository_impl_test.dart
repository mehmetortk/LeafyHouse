// test/data/repositories/plant_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:leafy_house/data/datasources/firestore_service.dart';
import 'package:leafy_house/data/repositories/plant_repository_impl.dart';
import 'package:leafy_house/domain/entities/plant.dart';

// Mock sınıfları oluşturun
class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  late PlantRepositoryImpl repository;
  late MockFirestoreService mockFirestoreService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    repository = PlantRepositoryImpl(mockFirestoreService);
  });

  test('fetchPlants returns a list of plants', () async {
    // Arrange
  when(mockFirestoreService.fetchPlants('userId')).thenAnswer((_) async => []);

    // Act
    final plants = await repository.fetchPlants('userId');

    // Assert
    expect(plants, isA<List<Plant>>());
    verify(mockFirestoreService.fetchPlants('userId')).called(1);
  });
}
