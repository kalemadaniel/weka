import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boat Seat Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 109, 45, 218),
        ),
        useMaterial3: true,
      ),
      home: const BookingPage(),
    );
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedIndex = DateTime.now().day - 1;
  late DateTime firstDayOfMonth;
  late DateTime lastDayOfMonth;
  final _scrollController = ScrollController();

  late List<String> seatStatus;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    firstDayOfMonth = DateTime(now.year, now.month, 1);
    lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Initialise tous les sièges à "available"
    seatStatus = List.generate(100, (index) => "available");

    // 18 sièges déjà pris (indices arbitraires)
    List<int> reservedSeats = [
      1,
      3,
      9,
      12,
      17,
      24,
      26,
      27,
      28,
      32,
      33,
      34,
      37,
      40,
      41,
      42,
      45,
      48,
      51,
      53,
      59,
      62,
      63,
      64,
      66,
      67,
      68,
      72,
      75,
      78,
      83,
      87,
      88,
      90,
      92,
      95,
      96,
      97,
      98,
      99,
    ];
    for (var seatIndex in reservedSeats) {
      seatStatus[seatIndex] = "taken";
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToSelectedIndex(),
    );
  }

  void _scrollToSelectedIndex() {
    _scrollController.animateTo(
      selectedIndex * 30.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleSeat(int index) {
    if (seatStatus[index] == "taken")
      return; // interdit de sélectionner un siège pris

    setState(() {
      if (seatStatus[index] == "available") {
        seatStatus[index] = "selected";
      } else if (seatStatus[index] == "selected") {
        seatStatus[index] = "available";
      }
    });
  }

  void _buyTicket() {
    String bookingId = "BT${Random().nextInt(999999)}";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketPage(
          bookingId: bookingId,
          seats: seatStatus
              .asMap()
              .entries
              .where((e) => e.value == "selected")
              .map((e) => e.key + 1)
              .toList(),
        ),
      ),
    );
  }

  Color getSeatColor(String status) {
    switch (status) {
      case "available":
        return Colors.white;
      case "taken":
        return const Color.fromARGB(255, 221, 55, 55); // rouge
      case "selected":
        return const Color.fromARGB(255, 109, 45, 218); // violet
      default:
        return Colors.white;
    }
  }

  double get totalPrice {
    int selectedCount = seatStatus
        .where((status) => status == "selected")
        .length;
    return selectedCount * 12.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xff181F21), Color(0xff1A1A1A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Agenda horizontal
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(lastDayOfMonth.day, (index) {
                        final currentDate = firstDayOfMonth.add(
                          Duration(days: index),
                        );
                        final dayName = DateFormat('E').format(currentDate);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Container(
                              width: 57,
                              height: 70,
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? const Color.fromARGB(255, 162, 38, 224)
                                    : const Color.fromARGB(255, 76, 96, 100),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    dayName.substring(0, 3),
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Heures
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            width: 100,
                            height: 25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: index == 2
                                  ? const Color.fromARGB(255, 162, 38, 224)
                                  : const Color.fromARGB(255, 76, 96, 100),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              '7:30 AM',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image du bateau
                  const SizedBox(height: 20),
                  Container(
                    height: 170,
                    width: double.infinity,
                    child: Image.asset(
                      'lib/images/bateau.png', // ton image locale
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sièges
                  Wrap(
                    spacing: 12,
                    children: List.generate(
                      100,
                      (index) => GestureDetector(
                        onTap: seatStatus[index] == "taken"
                            ? null
                            : () => _toggleSeat(index),
                        child: Icon(
                          Icons.chair,
                          color: getSeatColor(seatStatus[index]),
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Légende
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legendDot(Colors.white, "Disponible"),
                      _legendDot(
                        const Color.fromARGB(255, 221, 55, 55),
                        "Pris",
                      ),
                      _legendDot(
                        const Color.fromARGB(255, 109, 45, 218),
                        "Sélectionné",
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Bouton paiement
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    height: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xff292F30),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              "Port de Goma",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const Text(
                          "Voyage Goma vers Bukavu",
                          style: TextStyle(color: Colors.grey),
                        ),
                        ElevatedButton(
                          onPressed: seatStatus.any((s) => s == "selected")
                              ? _buyTicket
                              : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            fixedSize: const Size(230, 50),
                            backgroundColor:
                                seatStatus.any((s) => s == "selected")
                                ? const Color.fromARGB(255, 162, 38, 224)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Acheter le Ticket  \$${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}

class TicketPage extends StatelessWidget {
  final String bookingId;
  final List<int> seats;

  const TicketPage({super.key, required this.bookingId, required this.seats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Votre Ticket"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xff292F30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reservation ID: $bookingId",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Siège: ${seats.join(', ')}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: bookingId,
                width: 200,
                height: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Retourner à la réservation"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
