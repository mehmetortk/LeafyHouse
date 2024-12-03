// test/domain/usecases/add_plant_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:leafy_house/domain/entities/plant.dart';
import 'package:leafy_house/domain/interfaces/plant_repository.dart';
import 'package:leafy_house/domain/usecases/add_plant.dart';

// Mock sınıfı oluşturun
class MockPlantRepository extends Mock implements PlantRepository {}

void main() {
  late AddPlant addPlant;
  late MockPlantRepository mockPlantRepository;

  setUp(() {
    mockPlantRepository = MockPlantRepository();
    addPlant = AddPlant(mockPlantRepository);
  });

  test('addPlant calls repository to add a plant', () async {
    // Arrange
    final plant = Plant(
      id: '1',
      userId: 'userId',
      name: 'Plant Name',
      type: 'Type',
      moisture: 50,
      health: 'Healthy',
      imageUrl: '',
    );

    // Act
    await addPlant(plant);

    // Assert
    verify(mockPlantRepository.addPlant(plant)).called(1);
  });
}
