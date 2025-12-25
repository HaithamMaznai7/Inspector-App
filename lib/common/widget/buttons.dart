/*
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
class ProgressBtn extends StatefulWidget {
  ProgressBtn({super.key, this.isSubmiting = false, required this.checkSubmit, required this.title});

  final String title;
  bool isSubmiting;
  final bool Function() checkSubmit;
  @override
  State<ProgressBtn> createState() => _ProgressBtnState();
}

class _ProgressBtnState extends State<ProgressBtn> {
  void _submit(){
    setState(() {
      widget.isSubmiting = !widget.isSubmiting;
      widget.checkSubmit();
    });
  }
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: widget.isSubmiting ? 60 : FHelperFunctions.screenWidth() * .9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isSubmiting ? 100 : FSizes.borderRadiusLg),
          gradient: FColors.primaryGradient,
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent.withOpacity(0),
          elevation: 0,
          label: Container(
            child: widget.isSubmiting
                ? CircularProgressIndicator(color: Colors.white,)
                : Text('Next',style: Theme.of(context).textTheme.headlineMedium?.apply(
                color: FColors.white
            ),
            ),
          ),
          onPressed: widget.isSubmiting ? (){} : () => widget.checkSubmit(),
        ),
      );
  }
}



*/
