import 'dart:ui';
import 'package:flutter/material.dart';

late final FragmentShader shader;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  shader = (await FragmentProgram.fromAsset('shaders/glass.frag'))
      .fragmentShader();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> backgroundImages = [
    'https://picsum.photos/2000/2000',
    'https://picsum.photos/1200/1200',
    'https://picsum.photos/1400/1300',
    'https://picsum.photos/1100/1200',
  ];

  static const List<int> backgroundColors = [
    0xFF333333,
    0xFF33CCFF,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(backgroundColors.length, (index) {
                  return Container(
                    height: 500,
                    width: double.infinity,
                    color: Color(backgroundColors[index]),
                  );
                }),
                ...List.generate(backgroundImages.length, (index) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(backgroundImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Center(
            child: AppleGlassCard(),
          )
        ],
      ),
    );
  }
}

class AppleGlassCard extends StatefulWidget {
  const AppleGlassCard({super.key});

  @override
  State<AppleGlassCard> createState() => _AppleGlassCardState();
}

class _AppleGlassCardState extends State<AppleGlassCard> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double cardWidth = 340.0;
        const double cardHeight = 170.0;

        // Use devicePixelRatio for correct physical pixel calculations
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final physicalWidth = cardWidth * devicePixelRatio;
        final physicalHeight = cardHeight * devicePixelRatio;

        // Set shader uniforms
        shader.setFloat(0, physicalWidth); // u_resolution.x
        shader.setFloat(1, physicalHeight); // u_resolution.y

        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // SHADER Liquid Glass
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.shader(shader),
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // BLUR EFFECT
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),

                // CONTEÚDO DO CARD
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with avatar
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'TD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 2),
                                    Text(
                                      'Tiago Danin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Mobile Developer',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Online status indicator
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.withValues(alpha: 0.3),
                                      Colors.green.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Online',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Three buttons with icons on the right side
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_left,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),             
              ],
            ),
          ),
        );
      },
    );
  }
}
