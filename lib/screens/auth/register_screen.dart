import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final registered = await authProvider.register(
      name: _nameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      vehicle: _vehicleController.text.trim(),
    );

    if (registered && mounted) {
      final loggedIn = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (loggedIn && mounted) {
        context.go('/home');
      }
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header negro con título
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
            ),
            color: primaryBlack,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Registro',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Contenido con curva
          Expanded(
            child: Stack(
              children: [
                // Fondo negro que se ve detrás de la curva
                Container(height: 60, color: primaryBlack),
                // Contenedor blanco con curva
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          _buildLabel('Nombre:'),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Luis Arnulfo',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Apellido
                          _buildLabel('Apellido:'),
                          CustomTextField(
                            controller: _lastnameController,
                            hintText: 'Arce Catacora',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu apellido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Correo
                          _buildLabel('Correo:'),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'arnulfo@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Teléfono
                          _buildLabel('Teléfono:'),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: '70012345',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu teléfono';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Vehículo
                          _buildLabel('Vehículo:'),
                          CustomTextField(
                            controller: _vehicleController,
                            hintText: 'Moto Honda XR150',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu vehículo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          _buildLabel('Contraseña:'),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: '••••••••••',
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _register,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: primaryYellow,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Registrarse',
                                      style: GoogleFonts.montserratAlternates(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link a login
                          Center(
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.montserratAlternates(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Ya tienes una cuenta? '),
                                    TextSpan(
                                      text: 'Inicia sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryYellow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.montserratAlternates(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
