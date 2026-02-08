
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/routes.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OBDCodeCard extends StatelessWidget{
  final OBDCode code;
  const OBDCodeCard({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => InspectionObdBinding().instance.onCreateEdit(code: code),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: FSizes.sm),
        child: Row(
          children: [
            IconButton(
              onPressed: () => InspectionObdBinding().instance.delete(code),
              icon: Icon(Iconsax.trash)
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  ChoiceChip(
                    label: Text(code.code, style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
                    selected: true,
                    selectedColor: FColors.error.withOpacity(.7),
                    showCheckmark: false,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}