import 'package:fahis_inspector/features/inspection_photos/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_photos/models/photo.dart';
import 'package:fahis_inspector/features/inspection_photos/screens/editing_screen.dart';
import 'package:fahis_inspector/util/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumPhotos extends StatelessWidget {
  final controller = InspectionPhotosController.instance;
  AlbumPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Photos', style: Theme.of(context).textTheme.titleMedium),

              SizedBox(height: 16),
              SizedBox(height: 16),

              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  Get.to(InspectionPhotosScreen());
                },
              ),
            ],
          ),
          SizedBox(height: 16),

          Obx(() {
            List<Photo> photos =
                InspectionPhotosController.instance.photos.value;

            if (!controller.isLoading.value) {
              if (controller.photos.isEmpty) {
                return SizedBox();
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: photos.length <= 4 ? photos.length : 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2x2
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  if (photos.length > 4 && index == 3) {
                    return Stack(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: photos.length >= 7 ? 4 : photos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2x2
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            index = index == 0 ? 3 : index + 3;
                            if(photos.length > index){
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FImage(image: photos[index].image),
                              );
                            }else{
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FImage(image: photos[index].image),
                  );
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
        ],
      ),
    );
  }
}
