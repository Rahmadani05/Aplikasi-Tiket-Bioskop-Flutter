// lib/ticket_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tiket_model.dart';

class TicketPage extends StatefulWidget {
  TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final Stream<QuerySnapshot> _ticketsStream =
      FirebaseFirestore.instance
          .collection('tickets')
          .orderBy('bookingDate', descending: true)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ticketsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Jika terjadi error
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          // Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika tidak ada tiket sama sekali
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki tiket.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Jika data berhasil dimuat
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  // Ubah data map dari Firestore menjadi objek Ticket
                  final ticket = Ticket.fromMap(data);

                  // Tampilkan setiap tiket sebagai sebuah card
                  return TicketCard(ticket: ticket);
                }).toList(),
          );
        },
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ticket.posterPath,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.movieTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.cinemaMall,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ticket.selectedTime} • Kursi: ${ticket.selectedSeats.join(', ')}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${ticket.ticketId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
