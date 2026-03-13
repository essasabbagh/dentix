// import 'package:flutter/material.dart';

// class CustomBadge extends StatelessWidget {
//   const CustomBadge({
//     super.key,
//     this.label,
//     required this.child,
//     required this.isVisible,
//   });

//   final String? label;
//   final Widget child;
//   final bool isVisible;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.topRight,
//       children: <Widget>[
//         child,
//         Visibility(
//           visible: isVisible,
//           child: PositionedDirectional(
//             start: 0,
//             top: -8,
//             child: Container(
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.red,
//               ),
//               padding: const EdgeInsets.all(5),
//               child: Text(
//                 label!,
//                 style: const TextStyle(
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
