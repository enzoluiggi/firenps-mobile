import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculo simples de percentual NPS', () {
    const total = 10;
    const promoters = 6;
    const detractors = 2;

    final score = ((promoters - detractors) / total) * 100;

    expect(score, 40);
  });
}
