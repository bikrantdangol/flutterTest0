import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TrafficSimulationApp());
}

class TrafficSimulationApp extends StatelessWidget {
  const TrafficSimulationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepal Traffic Simulation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TrafficLightScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TrafficLightScreen extends StatefulWidget {
  const TrafficLightScreen({super.key});

  @override
  TrafficLightScreenState createState() => TrafficLightScreenState();
}

class TrafficLightScreenState extends State<TrafficLightScreen> {
  // Traffic light states
  final List<String> lightStates = ['red', 'yellow', 'green'];
  int currentLightIndex = 0;
  String currentLight = 'red';
  
  // Traffic light timing (in seconds) according to Nepal standards
  final Map<String, int> lightTimings = {
    'red': 10,    // Red light for 10 seconds
    'yellow': 2,  // Yellow light for 2 seconds
    'green': 5    // Green light for 5 seconds
  };
  
  // Car properties
  double carPosition = 0;
  bool carMoving = false;
  bool atCheckpoint = false;
  bool waitingForGreen = false;
  
  // Timer
  Timer? lightTimer;
  Timer? carTimer;
  int timeRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    timeRemaining = lightTimings[currentLight]!;
    _startLightTimer();
  }
  
  @override
  void dispose() {
    lightTimer?.cancel();
    carTimer?.cancel();
    super.dispose();
  }
  
  void _startLightTimer() {
    lightTimer?.cancel();
    lightTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining--;
        
        if (timeRemaining <= 0) {
          // Change to next light
          currentLightIndex = (currentLightIndex + 1) % lightStates.length;
          currentLight = lightStates[currentLightIndex];
          timeRemaining = lightTimings[currentLight]!;
          
          // If car is waiting for green and light turns green, start moving
          if (waitingForGreen && currentLight == 'green') {
            carMoving = true;
            waitingForGreen = false;
            _startCarMovement();
          }
        }
      });
    });
  }
  
  void _startCarMovement() {
    carTimer?.cancel();
    carTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!carMoving) {
        timer.cancel();
        return;
      }
      
      setState(() {
        carPosition += 3; // Move car
        
        // Check if car is at checkpoint (around 2/3 of the screen)
        final double checkpointPosition = MediaQuery.of(context).size.width * 0.65;
        
        if (carPosition >= checkpointPosition - 30 && carPosition <= checkpointPosition + 10) {
          atCheckpoint = true;
          
          // Apply traffic rules
          if (currentLight == 'green') {
            // Continue moving
          } else {
            carMoving = false;
            waitingForGreen = true;
            timer.cancel();
          }
        }
        
        // Reset car if it goes beyond screen
        if (carPosition > MediaQuery.of(context).size.width) {
          carPosition = 0;
        }
      });
    });
  }
  
  void _startSimulation() {
    setState(() {
      carMoving = true;
      _startCarMovement();
    });
  }
  
  void _resetSimulation() {
    setState(() {
      lightTimer?.cancel();
      carTimer?.cancel();
      
      currentLightIndex = 0;
      currentLight = 'red';
      timeRemaining = lightTimings[currentLight]!;
      
      carPosition = 0;
      carMoving = false;
      atCheckpoint = false;
      waitingForGreen = false;
      
      _startLightTimer();
    });
  }
  
  String _getStatusText() {
    if (!carMoving) {
      if (waitingForGreen) {
        if (currentLight == 'red') {
          return 'STOPPED (Waiting for Green Light)';
        } else if (currentLight == 'yellow') {
          return 'CAUTION (Prepare to Stop)';
        }
      }
      return 'STOPPED';
    } else {
      if (currentLight == 'green') {
        return 'MOVING (Green Light)';
      } else if (currentLight == 'yellow') {
        return 'MOVING (Caution)';
      } else {
        return 'MOVING (Should Stop!)';
      }
    }
  }
  
  Color _getStatusColor() {
    if (!carMoving) {
      if (waitingForGreen) {
        if (currentLight == 'yellow') {
          return Colors.orange;
        }
      }
      return Colors.red;
    } else {
      if (currentLight == 'green') {
        return Colors.green;
      } else if (currentLight == 'yellow') {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nepal Traffic Light Simulation'),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF4A6491)],
          ),
        ),
        child: Column(
          children: [
            // Status display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Light: ${currentLight.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getLightColor(currentLight),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time remaining: $timeRemaining seconds',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Road and simulation
            Expanded(
              child: Stack(
                children: [
                  // Road
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F8C8D),
                      border: Border.all(
                        color: const Color(0xFF636E72),
                        width: 8,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomPaint(
                      painter: RoadPainter(),
                    ),
                  ),
                  
                  // Car
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.4,
                    left: carPosition,
                    child: CarWidget(),
                  ),
                  
                  // Traffic light
                  Positioned(
                    top: 20,
                    right: 40,
                    child: TrafficLightWidget(currentLight: currentLight),
                  ),
                  
                  // Checkpoint
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.4 - 15,
                    left: MediaQuery.of(context).size.width * 0.65,
                    child: Container(
                      width: 4,
                      height: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  
                  // Checkpoint label
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    left: MediaQuery.of(context).size.width * 0.65 + 10,
                    child: const Text(
                      'Checkpoint',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _startSimulation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      carMoving ? 'PAUSE' : 'START',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetSimulation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'RESET',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getLightColor(String light) {
    switch (light) {
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.orange;
      case 'green':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    // Draw dashed center line
    final dashWidth = 10;
    final dashSpace = 15;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CarWidget extends StatelessWidget {
  const CarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Car body
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          
          // Windshield
          Positioned(
            top: 4,
            left: 8,
            child: Container(
              width: 20,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Wheels
          Positioned(
            bottom: -4,
            left: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrafficLightWidget extends StatelessWidget {
  final String currentLight;
  
  const TrafficLightWidget({super.key, required this.currentLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Red light
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: currentLight == 'red' ? Colors.red : Colors.red.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: currentLight == 'red'
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          
          // Yellow light
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: currentLight == 'yellow' ? Colors.orange : Colors.orange.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: currentLight == 'yellow'
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          
          // Green light
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: currentLight == 'green' ? Colors.green : Colors.green.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: currentLight == 'green'
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}