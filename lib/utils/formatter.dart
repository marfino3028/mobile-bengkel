const _months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String rupiah(num value) {
  final s = value.round().abs().toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write('.');
  }
  final formatted = buf.toString().split('').reversed.join();
  return '${value < 0 ? '-' : ''}Rp $formatted';
}

String fmtDate(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '-';
  return '${d.day} ${_months[d.month]} ${d.year}';
}

String fmtDateTime(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '-';
  return '${d.day} ${_months[d.month]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class StatusInfo {
  final String label;
  final int color;
  const StatusInfo(this.label, this.color);
}

StatusInfo statusInfo(String status) {
  switch (status) {
    case 'pending':
      return const StatusInfo('Menunggu', 0xFFF59E0B);
    case 'confirmed':
    case 'processing':
      return const StatusInfo('Diproses', 0xFF2563EB);
    case 'in_progress':
      return const StatusInfo('Dikerjakan', 0xFFF97316);
    case 'completed':
      return const StatusInfo('Selesai', 0xFF16A34A);
    case 'cancelled':
      return const StatusInfo('Dibatalkan', 0xFFEF4444);
    case 'paid':
      return const StatusInfo('Lunas', 0xFF16A34A);
    case 'unpaid':
      return const StatusInfo('Belum Bayar', 0xFF64748B);
    default:
      return StatusInfo(status, 0xFF64748B);
  }
}
