import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';

import '../../profile/data/mock_profile_repository.dart';
import '../../profile/domain/entities/health_option.dart';
import '../../profile/domain/usecases/get_allergies.dart';
import '../../profile/domain/usecases/get_conditions.dart';
import '../../profile/domain/usecases/get_profile.dart';
import '../../profile/domain/usecases/save_profile.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController ctrl;

  @override
  void initState() {
    super.initState();
    final repo = MockProfileRepository();
    ctrl = ProfileController(
      getProfileUsecase: GetProfile(repo),
      saveProfileUsecase: SaveProfile(repo),
      getAllergiesUsecase: GetAllergies(repo),
      getConditionsUsecase: GetConditions(repo),
    )..init();
    ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    ctrl.removeListener(_onChanged);
    ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Profile'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.person)),
          )
        ],
      ),
      body: Stack(
        children: [
          _Body(ctrl: ctrl),
          if (ctrl.loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: ctrl.loading ? null : () async {
              await ctrl.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved')), 
                );
              }
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Profile'),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProfileController ctrl;
  const _Body({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                _Field(
                  label: 'Name',
                  hint: 'Your name',
                  initial: ctrl.name,
                  onChanged: (v) => ctrl.name = v,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Age',
                  hint: 'e.g. 28',
                  keyboard: TextInputType.number,
                  initial: ctrl.ageText,
                  onChanged: (v) => ctrl.ageText = v,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Allergies & Sensitivities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 6),
          const Text('Select any allergies or food sensitivities you have', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _Card(
            child: _OptionsGrid(
              options: ctrl.allergies,
              isSelected: (id) => ctrl.selectedAllergyIds.contains(id),
              onTap: ctrl.toggleAllergy,
            ),
          ),

          const SizedBox(height: 20),
          const Text('Chronic Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
          const SizedBox(height: 6),
          const Text('Select any ongoing health conditions (optional)', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _Card(
            child: _OptionsGrid(
              options: ctrl.conditions,
              isSelected: (id) => ctrl.selectedConditionIds.contains(id),
              onTap: ctrl.toggleCondition,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboard;
  final String initial;
  final ValueChanged<String> onChanged;
  const _Field({
    required this.label,
    required this.hint,
    required this.initial,
    required this.onChanged,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initial);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.lightGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  final List<HealthOption> options;
  final bool Function(String id) isSelected;
  final void Function(String id) onTap;
  const _OptionsGrid({required this.options, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(12.0),
        child: CircularProgressIndicator(),
      ));
    }
    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.0,
      ),
      itemBuilder: (context, index) {
        final o = options[index];
        final id = o.id;
        final selected = isSelected(id);
        return InkWell(
          onTap: () => onTap(id),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.bgMintLight : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(o.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    o.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primaryDark : AppColors.text,
                    ),
                  ),
                ),
                Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? AppColors.primary : AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}
