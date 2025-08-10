// lib/seat_selection_page.dart

import 'package:flutter/material.dart';
import 'bioskop_page.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tiket_model.dart';
import 'tiket_sukses.dart';
import 'dart:math';

class SeatSelectionPage extends StatefulWidget {
  final Cinema cinema;
  final Movie movie;
  final String selectedTime;

  const SeatSelectionPage({
    super.key,
    required this.cinema,
    required this.movie,
    required this.selectedTime,
  });

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  // State untuk menyimpan kursi yang dipilih
  final Set<String> _selectedSeats = {};

  // Dummy data untuk kursi yang sudah dipesan
  final Set<String> _reservedSeats = {'B3', 'B4', 'F10', 'F11'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kursi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Layar Bioskop',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildSeatGrid(),
                ],
              ),
            ),
          ),
          buildBookingSummary(),
        ],
      ),
    );
  }

  Widget buildSeatGrid() {
    return Column(
      children: List.generate(8, (rowIndex) {
        String rowLabel = String.fromCharCode('A'.codeUnitAt(0) + rowIndex);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(12, (colIndex) {
            if (colIndex == 2 || colIndex == 9) {
              return const SizedBox(width: 20);
            }

            String seatId = '$rowLabel${colIndex + 1}';
            SeatStatus status;

            if (_reservedSeats.contains(seatId)) {
              status = SeatStatus.reserved;
            } else if (_selectedSeats.contains(seatId)) {
              status = SeatStatus.selected;
            } else {
              status = SeatStatus.available;
            }

            return SeatWidget(
              seatId: seatId,
              status: status,
              onTap: () {
                if (status == SeatStatus.available) {
                  setState(() {
                    _selectedSeats.add(seatId);
                  });
                } else if (status == SeatStatus.selected) {
                  setState(() {
                    _selectedSeats.remove(seatId);
                  });
                }
              },
            );
          }),
        );
      }),
    );
  }

  Widget buildBookingSummary() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed:
                _selectedSeats.isEmpty
                    ? null
                    : () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        final ticketId =
                            'TAD-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
                        final newTicket = Ticket(
                          ticketId: ticketId,
                          movieTitle: widget.movie.title,
                          cinemaMall: widget.cinema.mall,
                          selectedTime: widget.selectedTime,
                          selectedSeats: _selectedSeats.toList(),
                          totalPrice: 25000 * _selectedSeats.length,
                          bookingDate: DateTime.now(),
                          posterPath: widget.movie.posterPath,
                        );

                        final ticketsCollection = FirebaseFirestore.instance
                            .collection('tickets');
                        await ticketsCollection
                            .doc(newTicket.ticketId)
                            .set(newTicket.toMap());

                        Navigator.pop(context);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TicketSuccessPage(ticket: newTicket),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan tiket: $e')),
                        );
                      }
                    },
            child: const Text('Beli Tiket'),
          ),
        ],
      ),
    );
  }
}

// Enum untuk status kursi
enum SeatStatus { available, selected, reserved }

// Widget untuk merepresentasikan satu kursi
class SeatWidget extends StatelessWidget {
  final String seatId;
  final SeatStatus status;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seatId,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case SeatStatus.available:
        color = Colors.grey.shade300;
        break;
      case SeatStatus.selected:
        color = Colors.blue;
        break;
      case SeatStatus.reserved:
        color = Colors.red.shade400;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
