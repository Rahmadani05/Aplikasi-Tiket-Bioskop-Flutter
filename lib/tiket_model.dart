// lib/ticket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String ticketId;
  String movieTitle;
  String cinemaMall;
  String selectedTime;
  List<String> selectedSeats;
  int totalPrice;
  DateTime bookingDate;
  String posterPath;

  Ticket({
    required this.ticketId,
    required this.movieTitle,
    required this.cinemaMall,
    required this.selectedTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.bookingDate,
    required this.posterPath,
  });

  // Fungsi untuk mengubah objek Ticket menjadi Map agar bisa disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'movieTitle': movieTitle,
      'cinemaMall': cinemaMall,
      'selectedTime': selectedTime,
      'selectedSeats': selectedSeats,
      'totalPrice': totalPrice,
      'bookingDate': Timestamp.fromDate(
        bookingDate,
      ), // Simpan sebagai Timestamp
      'posterPath': posterPath,
    };
  }

  // Factory constructor untuk membuat objek Ticket dari data Firestore
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      ticketId: map['ticketId'],
      movieTitle: map['movieTitle'],
      cinemaMall: map['cinemaMall'],
      selectedTime: map['selectedTime'],
      selectedSeats: List<String>.from(map['selectedSeats']),
      totalPrice: map['totalPrice'],
      bookingDate:
          (map['bookingDate'] as Timestamp).toDate(), // Ambil sebagai Timestamp
      posterPath: map['posterPath'],
    );
  }
}
