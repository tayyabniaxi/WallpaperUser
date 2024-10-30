// // ignore_for_file: prefer_final_fields, unused_element

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:new_wall_paper_app/widgets/slider_widget.dart';

// class FullImageShowProvider extends ChangeNotifier {
//   double _exposure = 1.0;
//   double _contrast = 1.0;
//   double _saturation = 1.0;
//   double _highlight = 0.0;

//   double get exposure => _exposure;
//   double get contrast => _contrast;
//   double get saturation => _saturation;
//   double get hightLight => _highlight;

//   List<double> getColorMatrix() {
//     double contrast = _contrast;
//     double exposure = _exposure - 1.0;
//     double saturation = _saturation;
//     double highlight = _highlight;

//     return [
//       contrast * saturation + highlight,
//       0,
//       0,
//       0,
//       exposure * 255 * (1 - highlight),
//       0,
//       contrast * saturation + highlight,
//       0,
//       0,
//       exposure * 255 * (1 - highlight),
//       0,
//       0,
//       contrast * saturation + highlight,
//       0,
//       exposure * 255 * (1 - highlight),
//       0,
//       0,
//       0,
//       1,
//       0,
//     ];
//   }

//   void showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setBottomSheetState) {
//             return Padding(
//               padding: const EdgeInsets.all(6.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text("       "),
//                         const Text(
//                           'Adjust Filters',
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.bold),
//                         ),
//                         InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Icon(Icons.close)),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: buildSlider(
//                       label: "Exposure",
//                       value: _exposure,
//                       min: 0.5,
//                       max: 2.0,
//                       onChanged: (val) {
//                         setBottomSheetState(() => _exposure = val);
//                         notifyListeners();
//                       },
//                     ),
//                   ),
//                   buildSlider(
//                     label: "Contrast",
//                     value: _contrast,
//                     min: 0.5,
//                     max: 2.0,
//                     onChanged: (val) {
//                       setBottomSheetState(() => _contrast = val);
//                       notifyListeners();
//                     },
//                   ),
//                   buildSlider(
//                     label: "Saturation",
//                     value: _saturation,
//                     min: 0.0,
//                     max: 2.0,
//                     onChanged: (val) {
//                       setBottomSheetState(() => _saturation = val);
//                       notifyListeners();
//                     },
//                   ),
//                   buildSlider(
//                     label: "Highlight",
//                     value: _highlight,
//                     min: -0.5,
//                     max: 0.5,
//                     onChanged: (val) {
//                       setBottomSheetState(() => _highlight = val);
//                       notifyListeners();
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:new_wall_paper_app/widgets/slider_widget.dart';

class FullImageShowProvider extends ChangeNotifier {
  double _exposure = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _highlight = 0.0;

  double get exposure => _exposure;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get highlight => _highlight;

  // Getter to determine if any filter is active
  bool get isFilterActive =>
      _exposure != 1.0 || _contrast != 1.0 || _saturation != 1.0 || _highlight != 0.0;

  // Method to get the color matrix based on current filter values
  List<double> getColorMatrix() {
    double contrast = _contrast;
    double exposure = _exposure - 1.0;
    double saturation = _saturation;
    double highlight = _highlight;

    return [
      contrast * saturation + highlight, 0, 0, 0, exposure * 255 * (1 - highlight),
      0, contrast * saturation + highlight, 0, 0, exposure * 255 * (1 - highlight),
      0, 0, contrast * saturation + highlight, 0, exposure * 255 * (1 - highlight),
      0, 0, 0, 1, 0,
    ];
  }
 void resetFilters() {
    _exposure = 1.0;
    _contrast = 1.0;
    _saturation = 1.0;
    _highlight = 0.0;
    notifyListeners(); 
  }

  


  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setBottomSheetState) {
            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("       "),
                        const Text(
                          'Adjust Filters',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: buildSlider(
                      label: "Exposure",
                      value: _exposure,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (val) {
                        setBottomSheetState(() => _exposure = val);
                        notifyListeners();
                      },
                    ),
                  ),
                  buildSlider(
                    label: "Contrast",
                    value: _contrast,
                    min: 0.5,
                    max: 2.0,
                    onChanged: (val) {
                      setBottomSheetState(() => _contrast = val);
                      notifyListeners();
                    },
                  ),
                  buildSlider(
                    label: "Saturation",
                    value: _saturation,
                    min: 0.0,
                    max: 2.0,
                    onChanged: (val) {
                      setBottomSheetState(() => _saturation = val);
                      notifyListeners();
                    },
                  ),
                  buildSlider(
                    label: "Highlight",
                    value: _highlight,
                    min: -0.5,
                    max: 0.5,
                    onChanged: (val) {
                      setBottomSheetState(() => _highlight = val);
                      notifyListeners();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
