import 'package:fahis_inspector/common/widgets/components/back_page_button.dart';
import 'package:fahis_inspector/models/obd_code.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:fahis_inspector/util/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddingObdCode extends StatefulWidget {
  final OBDCode? code;
  
  const AddingObdCode({super.key, this.code});

  @override
  State<AddingObdCode> createState() => _AddingObdCodeState();
}

class _AddingObdCodeState extends State<AddingObdCode> {
  late TextEditingController _codeController;
  late TextEditingController _descController;
  bool isSearching = false;
  OBDCode? _code;

  @override
  Widget build(BuildContext context) {
    final isDark = FHelper.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add OBD code'.tr,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: FColors.white),
        ),
        centerTitle: true,
        backgroundColor: FColors.primaryColor,
        automaticallyImplyLeading: false,
        leading: BackPageButton( color: FColors.warning,),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: FSizes.md,
          horizontal: FSizes.appBarHeight
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    onChanged: (newValue) => _onChanged(newValue),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Type OBD code here'.tr,
                      focusColor: FColors.primaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _codeController.text = '';
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: isSearching
                          ? 'Searching Code Description...'.tr
                          : 'Type Code Description'.tr,
                      focusColor: FColors.primaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(FSizes.md),
                              child: CircularProgressIndicator(
                                color: FColors.primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _submit,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      FColors.primaryColor,
                    ),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: FColors.primaryColor),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Text(
                    'Add'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.apply(color: FColors.white),
                  ),
                ),
                TextButton(
                  onPressed: _cancelOrDelete,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      isDark ? FColors.dark.withOpacity(.4) : FColors.white,
                    ),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: FColors.primaryColor),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel'.tr,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.apply(color: FColors.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  @override
  void initState() {
    _code = widget.code;

    _codeController = TextEditingController();
    _descController = TextEditingController();

    _codeController.text = _code?.code ?? '';
    _descController.text = _code?.description ?? '';

    super.initState();
  }

  _submit() async {
    String code = _codeController.text;
    String description = _descController.text;
    if (_code == null) {
      _code = OBDCode(
        id: 0,
        code: code,
        description: description,
      );
    } else {
      _code!.code = code;
      _code!.description = description;
    }
    Get.back(result: _code);
  }

  _cancelOrDelete() {
    Get.back(result: null); // Close the dialog
  }

  _onChanged(String? value) async {
    if (value != null && value.length == 5) {
      // setState(() {
      //   isSearching = true ;
      // });
      // try{
      //   Network network = Network(endpoint: EndPoints.obdCodeSearch,requestMethod: RequestMethod.get );
      //   network.setQuery = {
      //     'obd_code': value,
      //   };
      //   CustomResponse? r = await network.response(RoutingUrl.login);
      //   if (r != null) {
      //     setState(() {
      //       isSearching = false;
      //       _descController.text = r.data['response']['obd_description'] ?? '';
      //     });
      //   }else{
      //     setState(() {
      //       isSearching = false ;
      //     });
      //   }
      // }catch(_){
      //   setState(() {
      //     isSearching = false ;
      //   });
      // }
    }
  }
}
