import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycards/providers/card_data_provider.dart';
import 'package:mycards/features/card_screens/custom_text_view.dart';

class EditMessageView extends ConsumerWidget {
  final String bgImage;

  /// Okay Motigbo Main
  const EditMessageView({
    super.key,
    required this.bgImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardData = ref.watch(cardEditingProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CustomTextView(
                  toMessage: cardData.to ?? "To Message",
                  fromMeassage: cardData.from ?? "From Message",
                  customMessage: cardData.greeting ?? "Main Message",
                  bgImageUrl: bgImage,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: GestureDetector(
              onTap: () {
                showEditTextModalBottom(
                  context,
                  ref,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange,
                ),
                height: 40,
                width: 40,
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showEditTextModalBottom(
  BuildContext context,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Customize Your Message",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 20),
            ),
          ),
          // To Message
          EditMessageOption(
            label: "To Message (Header)",
            initialValue: ref.read(cardEditingProvider).to ?? "To",
            onSave: (value) {
              ref
                  .read(cardEditingProvider.notifier)
                  .saveGreeting(value, null, null);
            },
          ),
          // Main Message
          EditMessageOption(
            label: "Main Message",
            initialValue: ref.read(cardEditingProvider).greeting ?? "Greeting",
            onSave: (value) {
              ref
                  .read(cardEditingProvider.notifier)
                  .saveGreeting(null, null, value);
            },
          ),
          // From Message
          EditMessageOption(
            label: "From Message (Footer)",
            initialValue: ref.read(cardEditingProvider).from ?? "From",
            onSave: (value) {
              ref
                  .read(cardEditingProvider.notifier)
                  .saveGreeting(null, value, null);
            },
          ),
          const SizedBox(height: 30),
        ],
      );
    },
  );
}

class EditMessageOption extends StatelessWidget {
  final String label;
  final String initialValue;
  final void Function(String) onSave;

  const EditMessageOption({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final value = await showEditDialog(context, label, initialValue);
        if (value != null) onSave(value);
      },
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Positioned(
                top: -2,
                left: 20,
                child: Text(label),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 40,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 20),
                        const Icon(Icons.edit_outlined),
                        const SizedBox(width: 10),
                        Text(initialValue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showEditDialog(
  BuildContext context,
  String title,
  String initialValue,
) async {
  String? value = initialValue;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (text) => value = text,
          controller: TextEditingController(text: initialValue),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
  return value;
}
