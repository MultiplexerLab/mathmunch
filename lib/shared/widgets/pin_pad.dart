import 'package:flutter/material.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/constants/app_constants.dart';

class PinPad extends StatelessWidget {
  final String currentPin;
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  const PinPad({
    super.key,
    required this.currentPin,
    required this.onDigit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots — AnimatedScale gives a pop when each digit is entered
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(AppConstants.parentPinLength, (i) {
            final filled = i < currentPin.length;
            return AnimatedScale(
              scale: filled ? 1.35 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.primary : AppColors.starEmpty,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        // Square cells (childAspectRatio: 1.0) so the circle always renders
        // correctly; _DigitButton uses a fixed 56×56 container so the InkWell
        // splash matches the visible circle on all screen sizes.
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: [
            ...List.generate(9, (i) => _DigitButton('${i + 1}', onDigit)),
            const SizedBox.shrink(),
            _DigitButton('0', onDigit),
            Center(
              child: IconButton(
                onPressed: onDelete,
                iconSize: 28,
                icon: const Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String digit;
  final void Function(String) onTap;

  const _DigitButton(this.digit, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => onTap(digit),
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceVariant,
          ),
          alignment: Alignment.center,
          child: Text(
            digit,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
