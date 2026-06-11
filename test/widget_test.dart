import 'package:flutter_test/flutter_test.dart';

import 'package:bengkel_mobile/utils/formatter.dart';

void main() {
  group('formatter', () {
    test('rupiah memformat ribuan dengan titik', () {
      expect(rupiah(55000), 'Rp 55.000');
      expect(rupiah(0), 'Rp 0');
      expect(rupiah(1234567), 'Rp 1.234.567');
    });

    test('statusInfo mengembalikan label Indonesia', () {
      expect(statusInfo('completed').label, 'Selesai');
      expect(statusInfo('unpaid').label, 'Belum Bayar');
    });
  });
}
