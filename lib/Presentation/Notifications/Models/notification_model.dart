import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationModel{

 final String notificationTitle;
 final String notificationContent;

 NotificationModel({
   required this.notificationContent,

   required this.notificationTitle
});

}

final todayDemoNotifications =[
  NotificationModel(
      notificationContent:"Khuyến mãi đặc biệt cho tới 25/6",
      notificationTitle:"Giảm giá 30% cho các đơn hàng Burger!"
  ),
  NotificationModel(
      notificationContent:"Mới đây",
      notificationTitle:"Đơn hàng đã được giao cho đơn vị vận chuyển"
  ),

];

final yesterdayDemoNotifications =[
  NotificationModel(
      notificationContent:"Special promotion only valid today",
      notificationTitle:"35% Special Discount!"
  ),
  NotificationModel(
      notificationContent:"Special promotion only valid today",
      notificationTitle:"Account Setup Successfull!"
  ),
  NotificationModel(
      notificationContent:"Special offer for new account, valid until 20 Nov 2022",
      notificationTitle:"Special Offer! 60% Off"
  ),
  NotificationModel(
      notificationContent:"Special promotion only valid today",
      notificationTitle:"Credit Card Connected"
  )
];
