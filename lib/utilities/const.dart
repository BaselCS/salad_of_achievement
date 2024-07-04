import 'package:flutter/material.dart';

const Color kActionColor = Color(0xFF4BA6A1);
const Color kBackGroundColor = Color(0xFF2C2F36);
const Color kInnerBackGroundColor = Color(0xFF45484F);
const Color kWhiteColor = Color(0xFFD4DBE1);
const Color kContainerColor = Color(0xFF1F2229);
const Color kBorderColor = Color(0xFF383B42);
const Color kStartsColor = Color(0xFFF6C950);

const String iconPath = 'assets/icons';
Image appIcon = Image.asset('$iconPath/appIcon.png');

Image orange = Image.asset('$iconPath/برتقال.png');
Image dragon = Image.asset('$iconPath/تنين.png');
Image pears = Image.asset('$iconPath/كمثرى.png');
Image lemon = Image.asset('$iconPath/ليمون.png');
Image tomato = Image.asset('$iconPath/طماطم.png');
Image strawberry = Image.asset('$iconPath/فرولة.png');
Image cherry = Image.asset('$iconPath/كرز.png');
Image pumpkin = Image.asset('$iconPath/يقطين.png');
Image banana = Image.asset("$iconPath/موز.png");

//fruits color
const Color kCherryColor = Color(0xFFF96464);
const Color kLemonColor = Color(0xFFFFCE29);
const Color kStrawberryColor = Color(0xFFEA4E4E);
const Color kOrangeColor = Color(0xFFFFA425);
const Color kTomatoColor = Color(0xFFE55C5C);
const Color kBananaColor = Color(0xFFFFC536);
const Color kPearsColor = Color(0xFF0BAD67);
const Color kPumpkinColor = Color(0xFFF2B816);
const Color kDragonColor = Color(0xFFDE5F5D);

Map<String, List> fruits = {
  "5": [cherry, kCherryColor],
  "10": [lemon, kLemonColor],
  "15": [strawberry, kStrawberryColor],
  "20": [orange, kOrangeColor],
  "25": [tomato, kTomatoColor],
  "30": [banana, kBananaColor],
  "40": [pears, kPearsColor],
  "50": [pumpkin, kPumpkinColor],
  "60": [dragon, kDragonColor],
};

const List<int> fruitsId = [5, 10, 15, 20, 25, 30, 40, 50, 60];
// النجوم
class Stars extends StatelessWidget {
  final bool isStar1;
  final bool isStar2;
  final bool isStar3;
  const Stars({
    super.key,
    this.isStar1 = false,
    this.isStar2 = false,
    this.isStar3 = false,
    
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.star, color: isStar1 ? kStartsColor : kBackGroundColor, size: 35),
      Icon(Icons.star, color: isStar2 ? kStartsColor : kBackGroundColor, size: 35),
      Icon(Icons.star, color: isStar3 ? kStartsColor : kBackGroundColor, size: 35)
    ]);
  }
}

class MyIcon extends StatelessWidget {
  final IconData icon;
  const MyIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(color: kActionColor, icon);
  }
}
