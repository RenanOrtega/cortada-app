import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateMatchPage extends ConsumerStatefulWidget {
  const CreateMatchPage({super.key});

  @override
  ConsumerState<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends ConsumerState<CreateMatchPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _customPlayersController =
      TextEditingController();

  String _matchType = 'Casual';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _matchFormat = '6x6';
  bool _isCustomFormat = false;
  String _privacyType = 'Pública';
  String _inviteCode = '';
  bool _isGeneratingCode = false;

  @override
  void dispose() {
    _locationController.dispose();
    _customPlayersController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _setCurrentDateTime() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  void _generateInviteCode() {
    setState(() {
      _isGeneratingCode = true;
      _inviteCode =
          'VBALL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isGeneratingCode = false;
        });
      });
    });
  }

  void _createMatch() {
    final matchData = {
      'type': _matchType,
      'date': _selectedDate,
      'time': '${_selectedTime.hour}:${_selectedTime.minute}',
      'location': _locationController.text,
      'format': _isCustomFormat ? _customPlayersController.text : _matchFormat,
      'privacy': _privacyType,
      'inviteCode': _privacyType == 'Privada' ? _inviteCode : null,
    };

    print('Criando partida: $matchData');

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Partida'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Tipo de Partida', Icons.sports_volleyball),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionButton(
                      'Casual',
                      _matchType == 'Casual',
                      () => setState(() => _matchType = 'Casual'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectionButton(
                      'Competitiva',
                      _matchType == 'Competitiva',
                      () => setState(() => _matchType = 'Competitiva'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Data e Hora', Icons.calendar_today),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(formattedDate),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(formattedTime),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _setCurrentDateTime,
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Agora'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Localização', Icons.location_on),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Nome da quadra ou local',
                  prefixIcon: const Icon(Icons.place, color: Colors.indigo),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: Colors.indigo),
                    onPressed: () {
                      // Aqui você integraria com o mapa
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Integração com mapa será implementada')),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Formato da Partida', Icons.people),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionButton(
                      '2x2',
                      _matchFormat == '2x2' && !_isCustomFormat,
                      () => setState(() {
                        _matchFormat = '2x2';
                        _isCustomFormat = false;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSelectionButton(
                      '4x4',
                      _matchFormat == '4x4' && !_isCustomFormat,
                      () => setState(() {
                        _matchFormat = '4x4';
                        _isCustomFormat = false;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSelectionButton(
                      '6x6',
                      _matchFormat == '6x6' && !_isCustomFormat,
                      () => setState(() {
                        _matchFormat = '6x6';
                        _isCustomFormat = false;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSelectionButton(
                'Personalizado',
                _isCustomFormat,
                () => setState(() => _isCustomFormat = true),
              ),
              if (_isCustomFormat) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _customPlayersController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Ex: 3x3, 5x5, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('Privacidade', Icons.lock),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionButton(
                      'Pública',
                      _privacyType == 'Pública',
                      () => setState(() => _privacyType = 'Pública'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectionButton(
                      'Privada',
                      _privacyType == 'Privada',
                      () => setState(() => _privacyType = 'Privada'),
                    ),
                  ),
                ],
              ),
              if (_privacyType == 'Privada') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Código de Convite:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_inviteCode.isEmpty && !_isGeneratingCode)
                        ElevatedButton.icon(
                          onPressed: _generateInviteCode,
                          icon: const Icon(Icons.vpn_key),
                          label: const Text('Gerar Código'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo,
                          ),
                        )
                      else if (_isGeneratingCode)
                        const Center(child: CircularProgressIndicator())
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.indigo.shade200),
                                ),
                                child: Text(
                                  _inviteCode,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon:
                                  const Icon(Icons.copy, color: Colors.indigo),
                              onPressed: () {
                                // Simulação de cópia para a área de transferência
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Código $_inviteCode copiado!')),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _createMatch,
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  label: const Text(
                    'CRIAR PARTIDA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionButton(
      String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
