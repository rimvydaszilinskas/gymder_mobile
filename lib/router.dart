import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:model/models/activity.dart';
import 'package:model/pages/activities/preview.dart';
import 'package:model/pages/register.dart';

class Router {
    /* Application router
     * Define custom routes here and what data is required to be passeds
     */
    static Route<dynamic> generateRoute(RouteSettings settings) {
        switch(settings.name) {
            case '/register':
                var data = settings.arguments as String;
                return MaterialPageRoute(builder: (_) => RegisterPage());
            case '/activity':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => ActivityPreview(data['activity'], data['user']));
            default:
                return MaterialPageRoute(builder: (_) => Scaffold());
        }
    }
}