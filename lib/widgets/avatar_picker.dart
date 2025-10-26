import 'package:flutter/material.dart';

class AvatarOption {
  final String emoji;
  final Color backgroundColor;

  const AvatarOption(this.emoji, this.backgroundColor);
}

class AvatarPicker extends StatelessWidget {
  final String? currentAvatar;
  final Function(String emoji, Color color) onAvatarSelected;

  const AvatarPicker({
    super.key,
    this.currentAvatar,
    required this.onAvatarSelected,
  });

  // Male and female color themes
  static const Color maleBaseColor = Color(0xFF1976D2);
  static const Color femaleBaseColor = Color(0xFFD81B60);
  
  // Predefined list of avatar options with emoji and background colors
  static const List<AvatarOption> avatarOptions = [
    // Male avatars (young to old)
    AvatarOption('👶', Color(0xFF90CAF9)), // Baby boy (light blue)
    AvatarOption('👦', Color(0xFF64B5F6)), // Young boy (medium blue)
    AvatarOption('👨', Color(0xFF1976D2)), // Adult man (blue)
    AvatarOption('👨‍🦰', Color(0xFF1565C0)), // Red-haired man (dark blue)
    AvatarOption('👨‍🦱', Color(0xFF0D47A1)), // Curly-haired man (deeper blue)
    AvatarOption('👴', Color(0xFF01579B)), // Elder man (darkest blue)

    // Female avatars (young to old)
    AvatarOption('👶', Color(0xFFF8BBD0)), // Baby girl (light pink)
    AvatarOption('👧', Color(0xFFF06292)), // Young girl (medium pink)
    AvatarOption('👩', Color(0xFFD81B60)), // Adult woman (pink)
    AvatarOption('👩‍🦰', Color(0xFFC2185B)), // Red-haired woman (dark pink)
    AvatarOption('👩‍🦱', Color(0xFFAD1457)), // Curly-haired woman (deeper pink)
    AvatarOption('👵', Color(0xFF880E4F)), // Elder woman (darkest pink)
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Choose Your Avatar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Male Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: maleBaseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Male',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: maleBaseColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: 6, // First 6 avatars (male)
            itemBuilder: (context, index) {
              final avatar = avatarOptions[index];
              final isSelected = currentAvatar == avatar.emoji;
              return _buildAvatarItem(context, avatar, isSelected, theme);
            },
          ),
          // Female Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: femaleBaseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Female',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: femaleBaseColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: 6, // Last 6 avatars (female)
            itemBuilder: (context, index) {
              final avatar = avatarOptions[index + 6]; // Offset by 6 for female avatars
              final isSelected = currentAvatar == avatar.emoji;
              return _buildAvatarItem(context, avatar, isSelected, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarItem(BuildContext context, AvatarOption avatar, bool isSelected, ThemeData theme) {
    return InkWell(
      onTap: () {
        onAvatarSelected(avatar.emoji, avatar.backgroundColor);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: avatar.backgroundColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : avatar.backgroundColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            avatar.emoji,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
